extends StaticBody3D

@onready var requirements_display: Label3D = $RequirementsDisplay
@onready var crafting: Node = $Components/Crafting

var tier: int = 0
@export var upgrade_requirements: Array[CraftingRecipe] = [
]

@onready var damageable: Node = $Components/Damageable
@onready var player = get_tree().get_first_node_in_group("player")
@onready var health_label: Label3D = $HealthLabel

func _ready() -> void:
	damageable.died.connect(_on_died)
	Global.update_health_display(health_label, damageable)
	display_requirements(false)

func take_damage(damage: float) -> void:
	damageable.take_damage(damage)
	Global.update_health_display(health_label, damageable)

func _on_died() -> void:
	player.die()

func get_requirements():
	return {tier + 1: upgrade_requirements[tier]}

func display_requirements(on: bool) -> void:
	requirements_display.visible = on
	if not on:
		return

	if tier > upgrade_requirements.size():
		requirements_display.text = "Höchste Stufe erreicht"
		return

	var recipe: CraftingRecipe = upgrade_requirements[tier]

	var tier_text = "Stufe %d" % (tier + 1)
	var requirements_list := []
	var has_all_resources := true  # assume player has everything

	for item_id in recipe.ingredients.keys():
		var required_amount = recipe.ingredients[item_id]

		# Get player's current amount
		var total = 0
		if is_instance_valid(crafting):
			var locations = crafting.inventory.inventory_contains(item_id)
			total = crafting.inventory.get_total_from_locations(locations)

		# If player doesn't have enough, mark it
		if total < required_amount:
			has_all_resources = false

		# Get item name
		var item_name = ItemIDs.get_item_name(item_id)

		# Format as "current / required ItemName"
		var ingredient_text = "%d / %d %s" % [total, required_amount, item_name]
		requirements_list.append(ingredient_text)

	# Join ingredients with commas
	var requirements_text = "Benötigt: " + String(", ").join(requirements_list)

	# Combine with tier and hint (only if player has all)
	var full_text = tier_text + "\n" + requirements_text
	if has_all_resources:
		full_text += "\nDrücke E zum Upgraden"

	# Set label
	requirements_display.text = full_text

# Call this from the player input when "interact" (E) is pressed
func try_craft_current_tier() -> void:
	# Check if tier exists
	if tier > upgrade_requirements.size():
		requirements_display.text = "Höchste Stufe erreicht"
		return
	
	var recipe: CraftingRecipe = upgrade_requirements[tier]
	
	if not crafting.craft(recipe):
		return
	
	# Advance to next tier
	tier += 1
	
	# Update the requirements display
	display_requirements(true)
