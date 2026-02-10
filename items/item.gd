extends Resource

class_name Item

@export var name: String
@export var icon: Texture2D
@export var count: int = 1
@export var scene: PackedScene
@export var sound: AudioStream
@export var item_id: Item_ids.ItemID
