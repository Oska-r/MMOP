extends StaticBody3D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var damageable: Node = $Components/Damageable
@onready var loot_table: Node = $Components/LootTable

func _ready() -> void:
	damageable.took_damage.connect(_on_damaged)

func _on_damaged(damage: float) -> void:
	loot_table.calculate_loot()

func take_damage(damage: int) -> void:
	damageable.take_damage(damage)
