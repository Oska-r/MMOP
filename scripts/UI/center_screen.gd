extends Control

@onready var crosshair_texture: TextureRect = $CrosshairTexture
@onready var slash_sound: AudioStreamPlayer = $SlashSound

@onready var attack_animation: AnimatedSprite2D = $AttackAnimation
@onready var break_animation: AnimatedSprite2D = $BreakAnimation

func _ready() -> void:
	attack_animation.hide()
	break_animation.hide()
	crosshair_texture.show()

func attacked(source: Node) -> void:
	crosshair_texture.hide()
	slash_sound.play()
	
	if source is Enemy:
		attack_animation.show()
		attack_animation.play()
	else:
		break_animation.show()
		break_animation.play()

func _on_attack_animation_animation_finished() -> void:
	attack_animation.hide()
	crosshair_texture.show()

func _on_break_slash_animation_finished() -> void:
	crosshair_texture.show()
	break_animation.hide()
