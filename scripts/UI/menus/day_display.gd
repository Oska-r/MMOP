extends RichTextLabel

func _ready() -> void:
	text = "Tag " + str(GlobalGameState.day_count)

func on_world_environment_day_started() -> void:
	text = "Tag " + str(GlobalGameState.day_count)
