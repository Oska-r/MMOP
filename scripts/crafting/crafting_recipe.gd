extends Button

@export var recipe: CraftingRecipe
@onready var recipe_label: RichTextLabel = $RecipeLabel
@onready var title: Label = $Title

var inventory: Control

func _ready() -> void:
	# Finds inventory by group
	inventory = get_tree().get_first_node_in_group("InventoryUI")
	
	# Connects the mouse filter fix
	recipe_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# For color changing
	recipe_label.bbcode_enabled = true
	
	# Initial UI sync
	update_current_amount()

## Updates the items the player currently has for the recipe.
func update_current_amount() -> void:
	if not recipe or not inventory: 
		return
	
	# 1. Get ingredient data (checking the first item in the recipe)
	var ingredient_id = recipe.ingredients.keys()[0]
	var required_amount = recipe.ingredients[ingredient_id]
	
	# 2. Get inventory data
	var locations = inventory.inventory_contains(ingredient_id)
	var total = inventory.get_total_from_locations(locations)
	
	# 3. Get item details for display
	var item_data = ItemIDs.get_item(ingredient_id)
	if item_data:
		var item_name = item_data.name
		
		# 4. Update the Label
		var color_code = "green" if total >= required_amount else "red"
		recipe_label.text = "[color=%s]%d[/color] / %d %s" % [color_code, total, required_amount, item_name]
	# Get the resource from the registry using the ID stored in the recipe
	var result_data = ItemIDs.get_item(recipe.result_item)
	print(result_data)
	
	if result_data:
		title.text = result_data.name 
	
	disabled = total < required_amount
