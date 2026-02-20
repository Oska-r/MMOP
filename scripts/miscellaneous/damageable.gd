extends Node
class_name Damageable

@export var max_health: float = 100.0
@onready var health: float = max_health 

func take_damage(damage: float) -> void: 
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	queue_free()
