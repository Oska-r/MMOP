extends Node

var day_count: int = 0
var gravity: float = 9.8

func _ready() -> void:
	await get_tree().process_frame  # wait until the first frame
	DisplayServer.window_set_min_size(Vector2i(1070, 600))

func reset_day() -> void:
	day_count = 0

func advance_day() -> void:
	day_count += 1

## Plays sound with randomized pitch to prevent sound fatigue. Accepts AudioStream, AudioStreamPlayer and AudioStreamPlayer3D.
func play_sound(sound, min_pitch: float = 0.9, max_pitch: float = 1.1) -> void:
	if not sound:
		return
		
	var player = sound
	
	if sound is AudioStream:
		player = AudioStreamPlayer.new()
		add_child(player)
		
		# connected signal for self deletion
		player.finished.connect(player.queue_free)
		player.stream = sound
	
	player.pitch_scale = randf_range(min_pitch, max_pitch)
	player.play()

func update_health_display(label: Label3D, damageable: Node) -> void:
	label.text = str(int(round(damageable.health))) + "/" + str(int(round(damageable.max_health)))

func rotate(object: Node, angle: int):
	var camera = get_viewport().get_camera_3d()

	if camera:
		# Make the label look at the camera
		object.look_at(camera.global_transform.origin, Vector3.UP)
		# Correct for flipping
		object.rotate_y(deg_to_rad(angle))
		# Keep label upright
		object.rotation.x = 0
		object.rotation.z = 0

func format_amount_text(current: int, required: int, item_name: String) -> String:
	var color = "green" if current >= required else "red"
	return "[color=%s]%d[/color] / %d %s" % [color, current, required, item_name]
