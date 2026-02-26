extends StaticBody3D

@onready var player = get_tree().get_first_node_in_group("player")

var health: int = 500

var loot_table: Dictionary = {Item_ids.ItemID.WOOD: 0.4}

func take_damage(damage: int) -> void:
	health -= damage
	calculate_loot()
	if health < 0:
		die()

func die() -> void:
	queue_free()

func calculate_loot() -> void:
	var roll: float = randf()
	for item in loot_table:
		if roll <= loot_table[item]:
			player.drop(item)
