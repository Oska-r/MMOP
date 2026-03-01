extends StaticBody3D

@onready var requirements_display: Label3D = $RequirementsDisplay

var tier: int = 0
var upgrade_requirements = [
	[{Item_ids.ItemID.WOOD: 4}],
	[{Item_ids.ItemID.OIL: 4}]
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
	if not on:
		requirements_display.visible = false
		return

	var tier_text = "Tier " + str(tier + 1)
	var tier_requirements = upgrade_requirements[tier][0]  # list of dicts
	var requirements_list := []

	# Build a readable list
	for item_id in tier_requirements.keys():
		var amount = tier_requirements[item_id]
		var item_name = ItemIDs.get_item_name(item_id)
		requirements_list.append("%dx %s" % [amount, item_name])

	# Join with commas using String.join()
	var requirements_text = "Benötigt: " + String(", ").join(requirements_list)

	# Combine with tier and hint
	var full_text = "%s\n%s\nDrücke E zum Upgraden" % [tier_text, requirements_text]

	# Set label text and show
	requirements_display.text = full_text
	requirements_display.visible = true
