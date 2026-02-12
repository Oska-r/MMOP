extends Control

@onready var label: Label = get_node("VBoxContainer/Label")

func _ready():
	get_tree().paused = false
	label.text = "Game Over!\nDu hast " + str(Global.day_count) + " Tage überlebt."
	visible = true

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

func _on_neustart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_beenden_pressed() -> void:
	get_tree().quit()
