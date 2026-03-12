extends StaticBody3D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var oxygen_tank = get_tree().get_first_node_in_group("oxygen_tank")
@onready var UI = get_tree().get_first_node_in_group("UI")

@onready var camera =  get_viewport().get_camera_3d()
@onready var label = $Label3D

var is_launching = false
var launch_speed = 15.0

func _ready() -> void:
	label.hide()

func spawned() -> void:
	label.show()

func launch_rocket() -> void:
	player.hide()
	label.hide()
	oxygen_tank.hide()
	UI.hide()
	player.enable_input(false)
	player.capture_mouse()
	is_launching = true

func _process(delta: float) -> void:
	if is_launching:
		global_translate(Vector3(0, launch_speed * delta, 0))
		camera.global_transform.origin = global_transform.origin + Vector3(0, 40, -10)
		camera.look_at(global_transform.origin, Vector3.UP)
		
		if transform.origin.y > 150:
			get_viewport().get_tree().change_scene_to_file("res://scenes/UI/menus/end_screen.tscn")
	
