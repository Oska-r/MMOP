extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.play("RESET")
	hide()

func _input(_event: InputEvent) -> void:
	if not player or not player.is_input_enabled():
		return
	if Input.is_action_just_pressed("ui_cancel") and !get_tree().paused:
		player.clear_preview()
		pause()
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		resume()

func resume() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	options.hide()
	hide()
	player.capture_mouse()

func pause() -> void:
	GlobalGameState.paused = true
	animation_player.play("blur")
	player.release_mouse()
	show()
	get_tree().paused = true

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().quit()

@export var options: Control

func _on_options_pressed() -> void:
	options.show()
