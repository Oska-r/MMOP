extends Node
class_name ItemIDs

enum ItemID {
	NONE,
	WOOD,
	STONE,
	SPIKES,
	OIL,
	RAW_IRON,
	SMELTED_IRON,
	FURNACE,
	CRAFTING_TABLE,
	MUSHROOM,
	WALL,
	LANTERN
}

const ITEM_REGISTRY := {
	ItemID.NONE: preload("res://items/inventory_items/none.tres"),
	ItemID.WOOD: preload("res://items/inventory_items/blocks/wood.tres"),
	ItemID.STONE: preload("res://items/inventory_items/blocks/stone.tres"),
	ItemID.SPIKES: preload("res://items/inventory_items/blocks/spikes.tres"),
	ItemID.OIL: preload("res://items/inventory_items/oil.tres"),
	ItemID.RAW_IRON: preload("res://items/inventory_items/raw_iron.tres"),
	ItemID.SMELTED_IRON: preload("res://items/inventory_items/smelted_iron.tres"),
	ItemID.FURNACE: preload("res://items/inventory_items/furnace.tres"),
	ItemID.CRAFTING_TABLE: preload("res://items/inventory_items/crafting_table.tres"),
	ItemID.MUSHROOM: preload("res://items/inventory_items/mushroom.tres"),
	ItemID.WALL: preload("res://items/inventory_items/wall.tres"),
	ItemID.LANTERN: preload("res://items/inventory_items/lantern.tres")
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
