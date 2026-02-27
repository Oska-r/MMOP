extends AnimatableBody3D

@onready var damageable: Node = $Components/Damageable
@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	damageable.died.connect(_on_died)

func take_damage(damage: float) -> void:
	print_debug("Oxygen took" + str(damage) + " damage")
	damageable.take_damage(damage)

func _on_died() -> void:
	player.die()
