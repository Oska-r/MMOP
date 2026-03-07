extends Node3D

@onready var background_music: AudioStreamPlayer = $BackgroundMusic

func _ready() -> void:
	background_music.stream.loop = true
	background_music.play()
	GlobalGameState.reset_day()
