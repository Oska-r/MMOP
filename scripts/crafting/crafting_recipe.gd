extends Button

@export var recipe: CraftingRecipe
@onready var recipe_label: RichTextLabel = $Container/RecipeLabel
@onready var title: Label = $Container/HBoxContainer/Title
@onready var texture_icon = $Container/HBoxContainer/TextureIcon

@onready var inventory: Control = get_tree().get_first_node_in_group("inventory")

func _ready() -> void:
	recipe_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# For color changing
	recipe_label.bbcode_enabled = true
	
	# Initial UI sync
	update_current_amount()

## Updates the items the player currently has for the recipe.
func update_current_amount() -> void:
	if not recipe or not inventory:
		return
	
	var display_text = ""
	
	# Loop through all ingredients in the recipe
	for ingredient_id in recipe.ingredients.keys():
		var required_amount = recipe.ingredients[ingredient_id]
		
		# Get total amount from inventory
		var locations = inventory.inventory_contains(ingredient_id)
		var total = inventory.get_total_from_locations(locations)
		
		# Get item details
		var item_data = ItemIDs.get_item(ingredient_id)
		if item_data:
			# Append each ingredients info to the display text
			display_text += UIHelper.format_amount_text(total, required_amount, item_data.name) + "\n"
	
	# Update the recipe label with all ingredients
	recipe_label.text = display_text.strip_edges()
	
	# Show the result item name and icon
	var result_data = ItemIDs.get_item(recipe.result_item)
	if result_data:
		title.text = result_data.name 
		texture_icon.texture = result_data.icon
	
	# Disable if any ingredient is insufficient
	var all_sufficient = true
	for ingredient_id in recipe.ingredients.keys():
		var required_amount = recipe.ingredients[ingredient_id]
		var total = inventory.get_total_from_locations(inventory.inventory_contains(ingredient_id))
		if total < required_amount:
			all_sufficient = false
			break
	
	disabled = not all_sufficient
