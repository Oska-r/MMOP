extends Control

@onready var background_music:AudioStreamPlayer = get_tree().get_first_node_in_group("background_music")

func _ready() -> void:
	hide()

var min_volume: float = -60.0
var max_volume: float = 0

func _on_music_volume_scrollbar_value_changed(value: float) -> void:
	var db: float
	if value == 0:
		db = -INF
	else:
		db = lerp(min_volume, max_volume, value / 100.0)
	
	background_music.volume_db = db


func _on_general_volume_scrollbar_value_changed(value: float) -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	
	var db: float
	if value == 0:
		db = -INF
	else:
		db = lerp(min_volume, max_volume, value / 100.0)
	
	AudioServer.set_bus_volume_db(master_bus, db)
