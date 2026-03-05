extends ReferenceRect

@export var inventory: Control
@export var crafting_sound: AudioStreamPlayer
@onready var crafting: Node  = $Components/Crafting

func _ready() -> void:
	for child in $Recipes.get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child))

## On crafting button pressed. Handles wether player has required ressources, if yes uses ressources and gives crafted item.
func _on_button_pressed(button: Button) -> void:
	if crafting.craft(button.recipe):
		SoundManager.play_sound(crafting_sound)
		button.update_current_amount()
