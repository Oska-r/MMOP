extends Control

@export var player: CharacterBody3D
@onready var health_display: Control = $HealthDisplay

@onready var crosshair = $Crosshair

@onready var attack_slashing_animation: AnimatedSprite2D = crosshair.get_node("AttackSlash")
@onready var break_slashing_animation: AnimatedSprite2D = crosshair.get_node("BreakSlash")
@onready var crosshair_texture = crosshair.get_node("CrosshairTexture")

func _on_player_player_health_changed(current_health: float, max_health: float) -> void:
	health_display.player_health_changed(current_health, max_health)

func _ready() -> void:
	attack_slashing_animation.hide()
	break_slashing_animation.hide()

func on_attacked(source: Node) -> void:
	crosshair_texture.hide()
	crosshair.get_node("AudioStreamPlayer").play()
	
	if source is Enemy:
		attack_slashing_animation.show()
		attack_slashing_animation.play("slashing")
	else:
		break_slashing_animation.show()
		break_slashing_animation.play("slashing")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	crosshair_texture.show()
	attack_slashing_animation.hide()


func _on_break_slash_animation_finished() -> void:
	crosshair_texture.show()
	break_slashing_animation.hide()
