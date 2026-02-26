extends RichTextLabel

func ready() -> void:
	text = "Tag " + str(Global.day_count)

func _on_world_environment_day_started() -> void:
	text = "Tag " + str(Global.day_count)
