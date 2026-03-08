extends Control

@onready var label: Label = get_node("VBoxContainer/Label")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	var unit = "Tage" if GlobalGameState.day_count != 1 else "Tag"
	
	if not GlobalGameState.won:
		label.text = "Game Over!\nDu hast %d %s überlebt." % [GlobalGameState.day_count, unit]
	else:
		label.text = "Du hast gewonnen! Dafür hast du %d %s gebraucht!" % [GlobalGameState.day_count, unit]
	visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_neustart_pressed() -> void:
	GlobalGameState.reset_day()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/menus/main_menu.tscn")

func _on_beenden_pressed() -> void:
	get_tree().quit()
