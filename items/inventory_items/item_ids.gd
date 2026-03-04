extends Node
class_name ItemIDs

enum ItemID {
	WOOD,
	STONE,
	SPIKE,
	OIL,
	IRON,
	SMELTED_IRON,
	FURNACE,
	NONE,
	CRAFTING_TABLE
}

const ITEM_REGISTRY := {
	ItemID.WOOD: preload("res://items/inventory_items/blocks/wood.tres"),
	ItemID.STONE: preload("res://items/inventory_items/blocks/stone.tres"),
	ItemID.SPIKE: preload("res://items/inventory_items/blocks/spikes.tres"),
	ItemID.OIL: preload("res://items/inventory_items/oil.tres"),
	ItemID.IRON: preload("res://items/inventory_items/iron.tres"),
	ItemID.SMELTED_IRON: preload("res://items/inventory_items/smelted_iron.tres"),
	ItemID.FURNACE: preload("res://items/inventory_items/furnace.tres"),
	ItemID.NONE: preload("res://items/inventory_items/none.tres"),
	ItemID.CRAFTING_TABLE: preload("res://items/inventory_items/crafting_table.tres")
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
