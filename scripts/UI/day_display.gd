extends RichTextLabel


func _on_world_environment_day_started(day_count: int) -> void:
	text = "Tag " + str(day_count)
