extends VBoxContainer

@onready var day_display: RichTextLabel = $DayDisplay

func _on_world_environment_day_started() -> void:
	day_display.on_world_environment_day_started()
