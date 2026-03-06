extends StaticBody3D

@onready var damageable: Node = $Components/Damageable
@onready var loot_table: Node = $Components/LootTable

func _ready() -> void:
	damageable.died.connect(_on_died)

func _on_died(_source: Node) -> void:
	loot_table.calculate_loot()
