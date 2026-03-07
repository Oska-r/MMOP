extends Node

@export var mob_scene: PackedScene

@onready var world: NavigationRegion3D = get_parent()
@onready var timer: Timer = $Timer

@export_category("Minimum Stats")
@export var min_enemy_speed:float = 3.0
@export var min_enemy_damage:float = 10.0
@export var min_enemy_health: float = 50.0

@export_category("Maximum Stats")
@export var max_speed: float = 8.0
@export var max_damage: float = 40.0
@export var max_health: float = 200.0

@export_category("Growth rate")
@export var growth_rate: float = 0.12

var current_enemy_speed: float = min_enemy_speed
var current_enemy_damage: float = min_enemy_damage
var current_enemy_health: float = min_enemy_health

func _process(delta: float) -> void:
	if world.is_day():
		for enemy in get_tree().get_nodes_in_group("enemy"):
			DamageSystem.apply_damage(self, world.sun_damage * delta, self)

func _on_timer_timeout() -> void:
	if world.is_day():
		return
	spawn_mob()

func spawn_mob() -> void:
	var mob = mob_scene.instantiate()
	apply_mob_stats(mob)
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	
	mob_spawn_location.progress_ratio = randf()
	mob.initialize(mob_spawn_location.position)
	
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func apply_mob_stats(mob) -> void:
	var body: Node3D = mob.get_node("Armature")
	var collision_shape: CollisionShape3D = mob.get_node("CollisionShape3D")
	var scale_factor: float = 1.0
	
	randomize_type(mob)
	
	mob.speed = current_enemy_speed
	mob.damage = current_enemy_damage
	mob.get_node("Components/Damageable").max_health = current_enemy_health
	
	match mob.type:
		EnemyTypes.EnemyType.NORMAL:
			pass
		
		EnemyTypes.EnemyType.SMALL:
			mob.speed *= 1.5
			scale_factor = 0.7
		
		EnemyTypes.EnemyType.BIG:
			mob.get_node("Components/Damageable").max_health *= 1.5
			scale_factor = 1.5
	
	# Apply scaling relative to the base scale
	body.scale *= scale_factor
	collision_shape.scale *= scale_factor

func randomize_type(mob) -> void:
	var random_type = randi() % EnemyTypes.EnemyType.size()
	mob.type = random_type as EnemyTypes.EnemyType

## Called from NavigationRegion3D.
func new_day() -> void:
	timer.calculate_wait_time(GlobalGameState.day_count)
	calculate_enemy_stats(GlobalGameState.day_count)
	print_day_stats(GlobalGameState.day_count)

func calculate_enemy_stats(day_count: int) -> void:
	current_enemy_speed = FunctionHelper.logistic_growth(min_enemy_speed, max_speed, growth_rate, day_count)
	current_enemy_damage = FunctionHelper.logistic_growth(min_enemy_damage, max_damage, growth_rate, day_count)
	current_enemy_health = FunctionHelper.logistic_growth(min_enemy_health, max_health, growth_rate, day_count)

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
		current_enemy_speed,
		current_enemy_damage,
		current_enemy_health
	])
