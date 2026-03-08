extends Node

func _ready() -> void:
	await get_tree().process_frame  # wait until the first frame
	DisplayServer.window_set_min_size(Vector2i(1070, 600))

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		var new_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED else DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(new_mode)

func update_health_display(label: Label3D, damageable: Node) -> void:
	label.text = str(int(round(damageable.health))) + "/" + str(int(round(damageable.max_health)))

func rotate(object: Node, angle: int, target = get_viewport().get_camera_3d()):
	if target:
		# Make the label look at the camera
		object.look_at(target.global_transform.origin, Vector3.UP)
		# Correct for flipping
		object.rotate_y(deg_to_rad(angle))
		# Keep it upright
		object.rotation.x = 0

func format_amount_text(current: int, required: int, item_name: String) -> String:
	var color = "green" if current >= required else "red"
	return "[color=%s]%d[/color] / %d %s" % [color, current, required, item_name]
