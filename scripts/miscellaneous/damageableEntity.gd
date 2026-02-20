extends CharacterBody3D
class_name DamageableEntity

@export var max_health: float = 100.0
@onready var health: float = max_health 

func take_damage(damage: float, should_drop_loot: bool = false) -> void: 
	health -= damage
	if health <= 0:
		die(should_drop_loot)

func die(_should_drop_loot: bool) -> void:
	queue_free()
