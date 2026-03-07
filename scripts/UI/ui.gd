extends Control

@export var player: CharacterBody3D
@onready var health_display: Control = $HealthDisplay

@onready var center_screen: Control = $CenterScreen

func _on_player_player_health_changed(current_health: float, max_health: float) -> void:
	health_display.player_health_changed(current_health, max_health)

func on_attacked(source: Node) -> void:
	center_screen.attacked(source)
