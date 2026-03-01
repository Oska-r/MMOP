extends Button

@export var recipe: CraftingRecipe
@onready var recipe_label: RichTextLabel = $Container/RecipeLabel
@onready var title: Label = $Container/HBoxContainer/Title
@onready var texture_icon = $Container/HBoxContainer/TextureIcon

@onready var inventory: Control = get_tree().get_first_node_in_group("inventory")

func _ready() -> void:
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
	
	# 1. Get ingredient data (taking first item in the recipe for now)
	var ingredient_id = recipe.ingredients.keys()[0]
	var required_amount = recipe.ingredients[ingredient_id]
	
	# 2. Get inventory data
	var locations = inventory.inventory_contains(ingredient_id)
	var total = inventory.get_total_from_locations(locations)
	
	# 3. Get item details for display
	var item_data = ItemIDs.get_item(ingredient_id)
	if item_data:
		recipe_label.text = Global.format_amount_text(total, required_amount, item_data.name)
	
	# 4. Show the result item name
	var result_data = ItemIDs.get_item(recipe.result_item)
	if result_data:
		title.text = result_data.name 
	texture_icon.texture = result_data.icon
	
	disabled = total < required_amount
