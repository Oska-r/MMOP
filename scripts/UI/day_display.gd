extends RichTextLabel


func _on_world_environment_day_started() -> void:
	text = "Tag " + str(Global.day_count)
