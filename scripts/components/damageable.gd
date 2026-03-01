extends Node
class_name Damageable

@export var max_health: float
@onready var health: float = max_health

signal died
signal took_damage(damage: float)

# returns wether entity dies from that damage tick
func take_damage(damage: float) -> bool:
	health -= damage
	emit_signal("took_damage", damage)
	if health <= 0:
		die()
		return true
	return false

func die() -> void:
	emit_signal("died")
	get_parent().get_parent().queue_free()
