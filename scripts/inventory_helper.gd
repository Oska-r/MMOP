extends Node

func find_stackable_or_empty(item_id, inventory) -> Vector2:
	var first_empty = Vector2(-1, -1)
	
	# Loop through player inventory (Rows 0-4)
	for r in range(5):
		for c in range(inventory.inventory_items[r].size()):
			var item = inventory.inventory_items[r][c]
			
			# If we find the same item, return this coordinate immediately (Stacking)
			if item != null and item.item_id == item_id:
				return Vector2(r, c)
			
			# If we find an empty slot, remember the FIRST one we saw
			if item == null and first_empty == Vector2(-1, -1):
				first_empty = Vector2(r, c)
				
	return first_empty
