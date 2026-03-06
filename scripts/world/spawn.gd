extends Node

@onready var world: NavigationRegion3D = get_parent()
@export var mob_scene: PackedScene
@onready var timer: Timer = get_node("Timer")

func _process(delta: float) -> void:
	if world.is_day():
		for enemy in get_tree().get_nodes_in_group("enemy"):
			DamageSystem.apply_damage(self, world.sun_damage * delta, self)

var timer_wait_time: float = 5.0
var min_wait_time: float = 1.0
@export var timer_decay_rate: float = 0.15

func calculate_wait_time(day_count: int) -> float:
	return scale_stat(timer_wait_time, min_wait_time, timer_decay_rate, day_count)

func _on_timer_timeout() -> void:
	if world.is_day():
		return
	spawn_mob()

var enemy_speed: float = 3.0
var enemy_damage: float = 10.0
var enemy_health: float = 50.0

var max_speed: float = 8.0
var max_damage: float = 40.0
var max_health: float = 200.0

var growth_rate: float = 0.12

func spawn_mob() -> void:
	var mob = mob_scene.instantiate()
	apply_mob_stats(mob)
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	
	mob_spawn_location.progress_ratio = randf()
	mob.initialize(mob_spawn_location.position)
	
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func apply_mob_stats(mob) -> void:
	var body: MeshInstance3D = mob.get_node("Body")
	var mat: StandardMaterial3D = body.material_override.duplicate()
	var collision_shape: CollisionShape3D = mob.get_node("CollisionShape3D")
	
	var color: Color = mat.albedo_color
	var scale_factor: float = 1.0
	
	randomize_type(mob)
	
	mob.speed = enemy_speed
	mob.damage = enemy_damage
	mob.get_node("Components/Damageable").max_health = enemy_health
	
	match mob.type:
		EnemyTypes.EnemyType.NORMAL:
			pass
		
		EnemyTypes.EnemyType.SMALL:
			mob.speed *= 1.5
			mat.albedo_color = color.lightened(1)
			scale_factor = 0.7
		
		EnemyTypes.EnemyType.BIG:
			enemy_health *= 1.5
			mat.albedo_color = color.darkened(1)
			scale_factor = 1.5
	
	# Apply scaling
	body.scale = Vector3.ONE * scale_factor
	collision_shape.scale = Vector3.ONE * scale_factor
	body.material_override = mat

func randomize_type(mob) -> void:
	var random_type = randi() % EnemyTypes.EnemyType.size()
	mob.type = random_type as EnemyTypes.EnemyType

func new_day() -> void:
	timer.wait_time = calculate_wait_time(GlobalGameState.day_count)
	calculate_enemy_stats(GlobalGameState.day_count)
	print_day_stats(GlobalGameState.day_count)

func calculate_enemy_stats(day_count: int) -> void:
	enemy_speed = scale_stat(3.0, max_speed,growth_rate, day_count)
	enemy_damage = scale_stat(10.0, max_damage,growth_rate, day_count)
	enemy_health = scale_stat(50.0, max_health,growth_rate, day_count)

func scale_stat(start_value: float, max_value: float, passed_growth_rate: float, day_count: int) -> float:
	return max_value - (max_value - start_value) * exp(passed_growth_rate * day_count)




func print_day_stats(day_count: int) -> void:
	print("""
	=== Day %d ===
	Timer Wait Time: %.2f
	Enemy Speed:     %.2f
	Enemy Damage:    %.2f
	Enemy Health:    %.2f
	""" % [
		day_count,
		timer.wait_time,
		enemy_speed,
		enemy_damage,
		enemy_health
	])
