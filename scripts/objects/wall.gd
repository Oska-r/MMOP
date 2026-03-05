extends StaticBody3D

@onready var damageable: Node = $Components/Damageable
@onready var loot_table: Node = $Components/LootTable

func _ready() -> void:
	damageable.took_damage.connect(_took_damage)

func _took_damage(damge: int, source: Node) -> void:
	loot_table.calculate_loot()
