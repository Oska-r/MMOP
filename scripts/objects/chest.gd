extends StaticBody3D

var is_open: bool = false

@export var chest_items: Array[Item] = [null,null,null,null, null,null,null,null,null,null]

@export var open_chest_sound: AudioStreamPlayer3D
@export var close_chest_sound: AudioStreamPlayer3D

@onready var inventory: Control = get_tree().get_first_node_in_group("inventory")
@onready var damageable: Node = $Components/Damageable
@onready var loot_table: Node = $Components/LootTable

func _ready() -> void:
	damageable.died.connect(_on_died)
	# Keep your duplication logic
	for i in range(chest_items.size()):
		if chest_items[i] is Item:
			chest_items[i] = chest_items[i].duplicate()

# Source is always player.
func _on_died(_source: Node) -> void:
	loot_table.calculate_loot()
	for i in chest_items.size():
		var item = chest_items[i]
		
		if not item:
			continue
		
		inventory.drop(item.item_id, item.count)

func _unhandled_input(event: InputEvent) -> void:
	if is_open and (event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel")):
		toggle_chest()

## ChatGPT Code for animation.
func toggle_chest() -> void:
	is_open = not is_open
	
	if is_open:
		open_chest()
	else:
		close_chest()

func open_chest() -> void:
	SoundManager.play_sound(open_chest_sound)
	inventory.open_chest(self)

func close_chest() -> void:
	SoundManager.play_sound(close_chest_sound, 1.7, 1.9)
	inventory.close_chest(self)

## Overwrites chest content with the new one when player changed items in the chest (called from inventory).
func update(new_chest_items) -> void:
	for i in chest_items.size():
		chest_items[i] = new_chest_items[i]
