extends Node

@onready var inventory: Control = get_tree().get_first_node_in_group("inventory")

func craft(recipe: CraftingRecipe) -> bool:
	# 1. Check if player has enough of each ingredient
	for ingredient_id in recipe.ingredients.keys():
		var required_amount = recipe.ingredients[ingredient_id]
		var locations = inventory.inventory_contains(ingredient_id)
		var total = inventory.get_total_from_locations(locations)
		if total < required_amount:
			print("Not enough of item:", ItemIDs.get_item_name(ingredient_id))
			return false
	
	# 2. Find where to put the result
	var result_id = recipe.result_item
	var target_slot = inventory.slot_to_put_in(result_id)
	if target_slot == Vector2(-1, -1):
		print("Inventory full!")
		return false

	# 3. Consume each ingredient
	for ingredient_id in recipe.ingredients.keys():
		var required_amount = recipe.ingredients[ingredient_id]
		var remaining_to_consume = required_amount
		
		# Create a list of coordinates and counts
		var locations_dict = inventory.inventory_contains(ingredient_id)
		var slots = []
		for coords in locations_dict.keys():
			slots.append({ "coords": coords, "count": locations_dict[coords] })
		
		for slot_data in slots:
			if remaining_to_consume <= 0:
				break
			var coords: Vector2 = slot_data["coords"]
			var row = int(coords.x)
			var col = int(coords.y)
			var amount_in_slot = slot_data["count"]
			
			if amount_in_slot <= remaining_to_consume:
				remaining_to_consume -= amount_in_slot
				inventory.clear_inventory_slot(row, col)
			else:
				inventory.change_count(-remaining_to_consume, row, col)
				remaining_to_consume = 0
	
	# 4. Add the crafted item
	if result_id != ItemIDs.ItemID.NONE:
		inventory.load_item_to_inventory(result_id, int(target_slot.x), int(target_slot.y), 1)
	inventory.hotbar.update_hotbar_ui()
	
	return true
