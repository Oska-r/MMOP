extends Node

@onready var player = get_tree().get_first_node_in_group("player")

## Dictionary das items eine Droppwarscheinlichkeit zuordnet
@export var loot_table: Dictionary[Item_ids.ItemID, float] = {}

func calculate_loot() -> void:
	## zufallszahl zwischen 0 und 1
	var roll: float = randf()
	for item in loot_table:
		if roll <= loot_table[item]:
			player.drop(item)
