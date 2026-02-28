extends StaticBody3D

@onready var damageable: Node = $Components/Damageable
@onready var player = get_tree().get_first_node_in_group("player")
@onready var health_label: Label3D = $HealthLabel

func _ready() -> void:
	damageable.died.connect(_on_died)
	Global.update_health_display(health_label, damageable)

func take_damage(damage: float) -> void:
	damageable.take_damage(damage)
	Global.update_health_display(health_label, damageable)

func _on_died() -> void:
	player.die()
