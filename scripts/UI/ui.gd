extends Control

@export var player: CharacterBody3D
@onready var health_display: Control = $HealthDisplay

@onready var crosshair = $Crosshair

@onready var slashing_animation: AnimatedSprite2D = crosshair.get_node("AnimatedSprite2D")
@onready var crosshair_texture = crosshair.get_node("CrosshairTexture")

func _on_player_player_health_changed(current_health: float, max_health: float) -> void:
	health_display.player_health_changed(current_health, max_health)

func _ready() -> void:
	slashing_animation.hide()

func on_attacked() -> void:
	crosshair_texture.hide()
	slashing_animation.show()
	slashing_animation.play("slashing")
	crosshair.get_node("AudioStreamPlayer").play()

func _on_animated_sprite_2d_animation_finished() -> void:
	crosshair_texture.show()
	slashing_animation.hide()
