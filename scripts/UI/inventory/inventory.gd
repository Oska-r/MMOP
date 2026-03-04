extends Control

@onready var player: CharacterBody3D = get_parent().player
@export var hotbar: Control
@onready var chest: Control = $Chest
@onready var crafting_table: Control = $CraftingTable
@onready var main_inventory: Control = $MainInventory
@onready var furnace: Control = $Furnace

# row 0 for hotbar, row 5 for chests
var inventory_items: Array[Array] = [
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null, null, null]
]

func get_hotbar_items() -> Array:
	return inventory_items[0]

func _ready() -> void:
	load_item_to_inventory(Item_ids.ItemID.STONE,0,0,30)
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	chest.hide()
	crafting_table.hide()
	furnace.hide()

func _input(event) -> void:
	if event.is_action_pressed("inventory"):
		player.clear_preview()
		if visible:
			close_inventory()
		else:
			open_inventory()

func drop(item: Item_ids.ItemID) -> void:
	var target = find_stackable_or_empty(item)
	if target == Vector2(-1, -1):
		print("Inventory full!")
		return
	load_item_to_inventory(item, int(target.x), int(target.y), 1)

func swap_inventory_slots(originalRow: int, originalIndex: int, targetRow: int, targetIndex: int) -> void:
	var item_a = inventory_items[originalRow][originalIndex]
	var item_b = inventory_items[targetRow][targetIndex]
	
	# 1. If we are dragging nothing, do nothing
	if item_a == null:
		return

	# 2. If target is empty, just move it
	if item_b == null:
		load_item_to_inventory(item_a.item_id, targetRow, targetIndex, item_a.count)
		clear_inventory_slot(originalRow, originalIndex)
		
	# 3. If target is the SAME item type, stack them
	elif item_b.item_id == item_a.item_id:
		change_count(item_a.count, targetRow, targetIndex)
		clear_inventory_slot(originalRow, originalIndex)
		
	# 4. If target is a DIFFERENT item type, swap them
	else:
		# Temporarily hold item_a's data
		var temp_id = item_a.item_id
		var temp_count = item_a.count
		
		# Move item_b to original slot
		clear_inventory_slot(originalRow, originalIndex)
		load_item_to_inventory(item_b.item_id, originalRow, originalIndex, item_b.count)
		
		# Move item_a to target slot
		clear_inventory_slot(targetRow, targetIndex)
		load_item_to_inventory(temp_id, targetRow, targetIndex, temp_count)

## Removes item (both visually and in code) from the inventory at given row and index.
func clear_inventory_slot(row: int, index: int) -> void:
	inventory_items[row][index] = null

	var slot_node = get_slot_node(row, index)

	var icon_node = slot_node.get_node("Item") as TextureRect
	if icon_node:
		icon_node.texture = null

	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = ""

## Load a item (identified by ItemID) at specified row and specified index with specified count to the inventory.
func load_item_to_inventory(item_id: Item_ids.ItemID, row: int = 0, index: int = 0, count: int = 1) -> Item:
	var original_item = inventory_items[row][index]
	
	if original_item and original_item.item_id != item_id:
		return
	
	if original_item and original_item.item_id == item_id:
		change_count(count, row, index)
		return
	
	var item: Item = ItemIDs.get_item(item_id)
	inventory_items[row][index] = item
	item.count = count
	
	var slot_node = get_slot_node(row, index)
	var icon_node = slot_node.get_node("Item") as TextureRect
	icon_node.texture = item.icon

	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = str(item.count)
	
	if row == 0:
		hotbar.update_hotbar_ui()
	
	return item

func change_count(number: int, row: int, index: int) -> void:
	var item: Item = inventory_items[row][index]
	if item == null:
		return

	item.count += number

	# If count is zero or less, remove the item completely
	if item.count <= 0:
		clear_inventory_slot(row, index)
		return
	
	var slot_node = get_slot_node(row, index)
	
	var count_label = slot_node.get_node("Count") as RichTextLabel
	if count_label:
		count_label.text = str(item.count)
	
	if row == 0:
		hotbar.update_hotbar_ui()

func get_slot_node(row: int, index: int) -> Node:
	var path
	if row == 0:
		path = "MainInventory/InventoryContainer/row_0"
	elif row == 5:
		path = "Chest/ChestBackground/row_5"
	else:
		path = "MainInventory/InventoryContainer/SlotContainer/row_%d" % row
	return get_node(path).get_child(index)

func open_inventory() -> void:
	hotbar.hide()
	visible = true
	player.enable_input(false)

func close_inventory() -> void:
	hotbar.show()
	visible = false
	player.enable_input(true)
	hotbar.update_hotbar_ui()

func open_chest(opened_chest:  StaticBody3D) -> void:
	var chest_items = opened_chest.chest_items
	
	open_inventory()
	chest.show()
	
	for i in chest_items.size():
		var item = chest_items[i]
		if item:
			load_item_to_inventory(item.item_id, 5, i, item.count)

func close_chest(opened_chest: StaticBody3D) -> void:
	close_inventory()
	chest.hide()
	var chest_items = opened_chest.chest_items
	
	opened_chest.update(inventory_items[5])
	
	for i in chest_items.size():
		clear_inventory_slot(5, i)

func open_crafting_table() -> void:
	open_inventory()
	crafting_table.show()
	crafting_table.get_node("Recipes/Spikes").update_current_amount()#
	crafting_table.get_node("Recipes/Furnace").update_current_amount()

func close_crafting_table() -> void:
	close_inventory()
	crafting_table.hide()

func open_furnace() -> void:
	open_inventory()
	furnace.show()
	furnace.get_node("Recipes/Iron").update_current_amount()

func close_furnace() -> void:
	close_inventory()
	furnace.hide()

## Returns the total amount of a specific item currently held in the inventory.
func inventory_contains(target_id: ItemIDs.ItemID) -> Dictionary:
	var locations = {}
	for row_index in range(inventory_items.size()):
		var row = inventory_items[row_index]
		for slot_index in range(row.size()):
			var item = row[slot_index]
			# Now we are comparing int to int (the enum values)
			if item != null and item.item_id == target_id:
				var coords = Vector2(row_index, slot_index)
				locations[coords] = item.count
	return locations

## Takes the dictionary from inventory_contains and returns the total sum of items.
func get_total_from_locations(locations: Dictionary) -> int:
	var sum: int = 0
	for count in locations.values():
		sum += count
	return sum

## Searches for an existing stack of the same ID or the first empty slot.
func find_stackable_or_empty(item_id) -> Vector2:
	var first_empty = Vector2(-1, -1)
	
	# Loop through player inventory (Rows 0-4)
	for r in range(5):
		for c in range(inventory_items[r].size()):
			var item = inventory_items[r][c]
			
			# If we find the same item, return this coordinate immediately (Stacking)
			if item != null and item.item_id == item_id:
				return Vector2(r, c)
			
			# If we find an empty slot, remember the FIRST one we saw
			if item == null and first_empty == Vector2(-1, -1):
				first_empty = Vector2(r, c)
				
	return first_empty
