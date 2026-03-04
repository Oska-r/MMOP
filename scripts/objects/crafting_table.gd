extends StaticBody3D

@onready var inventory: Control = get_tree().get_first_node_in_group("inventory")
var is_open: bool = false

@onready var damageable: Node = $Components/Damageable
@onready var loot_table: Node = $Components/LootTable

func _ready() -> void:
	damageable.took_damage.connect(_on_damaged)

func _on_damaged(damage: float, source: Node) -> void:
	loot_table.calculate_loot()

func _unhandled_input(event: InputEvent) -> void:
	if is_open and (event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel")):
		toggle_crafting_table()

func toggle_crafting_table():
	is_open = not is_open
	
	if is_open:
		inventory.open_crafting_table()
	else:
		inventory.close_crafting_table()
