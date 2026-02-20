extends Node3D

@export var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player.stream.loop = true
	music_player.play()
