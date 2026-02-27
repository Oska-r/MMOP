extends Node

@onready var world: NavigationRegion3D = get_parent()
@export var mob_scene: PackedScene
@onready var timer: Timer = get_node("Timer")

var enemy_speed: float = 3.0
var enemy_damage: float = 10.0
var enemy_health: float = 50.0

func new_day() -> void:
	timer.wait_time = calculate_wait_time(Global.day_count)
	calculate_enemy_stats(Global.day_count)
	print_day_stats(Global.day_count)

var timer_wait_time: float = 5.0
var min_wait_time: float = 1.0
@export var timer_decay_rate: float = 0.15

func calculate_wait_time(day_count: int) -> float:
	return scale_stat(timer_wait_time, min_wait_time, timer_decay_rate, day_count)

var max_speed: float = 8.0
var max_damage: float = 40.0
var max_health: float = 200.0

var growth_rate: float = 0.12

func calculate_enemy_stats(day_count: int) -> void:
	enemy_speed = scale_stat(3.0, max_speed,growth_rate ,day_count)
	enemy_damage = scale_stat(10.0, max_damage,growth_rate, day_count)
	enemy_health = scale_stat(50.0, max_health,growth_rate, day_count)

func scale_stat(start_value: float, max_value: float, growth_rate: float, day_count: int) -> float:
	return max_value - (max_value - start_value) * exp(-growth_rate * day_count)

func _process(delta: float) -> void:
	if world.is_day():
		get_tree().call_group("enemy", "sun_damage", world.sun_damage * delta)

func _on_timer_timeout() -> void:
	if world.is_day():
		return
	spawn_mob()

func apply_mob_stats(mob) -> void:
	mob.speed = enemy_speed
	mob.damage = enemy_damage
	mob.get_node("Components/Damageable").health = enemy_health

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

func spawn_mob() -> void:
	var mob = mob_scene.instantiate()
	apply_mob_stats(mob)
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# offset -> enemys don't spawn in the same location
	mob_spawn_location.progress_ratio = randf()
	mob.initialize(mob_spawn_location.position)
	
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
