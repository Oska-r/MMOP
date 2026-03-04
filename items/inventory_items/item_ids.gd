extends Node
class_name ItemIDs

enum ItemID {
	WOOD,
	STONE,
	SPIKE,
	OIL,
	IRON,
	NONE
}

const ITEM_REGISTRY := {
	ItemID.WOOD: preload("res://items/inventory_items/blocks/wood.tres"),
	ItemID.STONE: preload("res://items/inventory_items/blocks/stone.tres"),
	ItemID.SPIKE: preload("res://items/inventory_items/blocks/spikes.tres"),
	ItemID.OIL: preload("res://items/inventory_items/oil.tres"),
	ItemID.IRON: preload("res://items/inventory_items/iron.tres"),
	ItemID.NONE: preload("res://items/inventory_items/none.tres")
}

static func get_item(id: ItemID) -> Item:
	if ITEM_REGISTRY.has(id):
		return ITEM_REGISTRY[id].duplicate()
	return null

static func get_item_name(id: ItemID) -> String:
	var item_res := get_item(id)
	if item_res != null:
		return item_res.name
	return "Unknown Item"
