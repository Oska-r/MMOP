extends StaticBody3D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label3D

func _ready() -> void:
	display_requirements(false)

func pickup_mushroom() -> void:
	player.drop(Item_ids.ItemID.MUSHROOM)
	queue_free()

func display_requirements(on: bool) -> void:
	print_debug("Mushroom displayed")
	label.visible = on
