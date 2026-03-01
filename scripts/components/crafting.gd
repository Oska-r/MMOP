extends Node

@onready var inventory: Control = get_tree().get_first_node_in_group("inventory")

func craft(recipe: CraftingRecipe) -> bool:
	var ingredient_id = recipe.ingredients.keys()[0]
	var required_amount = recipe.ingredients[ingredient_id]
	var result_id = recipe.result_item
	
	# 1. Check ingredients
	var locations = inventory.inventory_contains(ingredient_id)
	var total = inventory.get_total_from_locations(locations)
	
	if total < required_amount:
		print("Not enough ingredients!")
		return false

	# 2. Find where to put the result
	var target_slot = inventory.find_stackable_or_empty(result_id)
	if target_slot == Vector2(-1, -1):
		print("Inventory full!")
		return false
	
	# 3. Consume ingredients
	var remaining_to_consume = required_amount
	
	for coords in locations.keys():
		if remaining_to_consume <= 0: break
		var row = int(coords.x)
		var col = int(coords.y)
		var amount_in_slot = locations[coords]
		
		if amount_in_slot <= remaining_to_consume:
			remaining_to_consume -= amount_in_slot
			inventory.clear_inventory_slot(row, col)
		else:
			inventory.change_count(-remaining_to_consume, row, col)
			remaining_to_consume = 0
	
	# 4. Add the item (load_item_to_inventory handles both new and existing stacks)
	if not result_id == Item_ids.ItemID.NONE:
		inventory.load_item_to_inventory(result_id, int(target_slot.x), int(target_slot.y), 1)
	return true
