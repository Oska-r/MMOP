extends Node
class_name Damageable

@export var max_health: float
@onready var health: float = max_health

signal died(source: Node)
signal took_damage(damage: float, source: Node)

# returns wether entity dies from that damage tick
func take_damage(damage: float, source: Node) -> bool:
	health -= damage
	emit_signal("took_damage", damage, source)
	if health <= 0:
		die(source)
		return true
	return false

func die(source: Node) -> void:
	emit_signal("died", source)
	get_parent().get_parent().queue_free()
