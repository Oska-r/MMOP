extends Label3D
# Reference to the camera, if needed
@onready var camera = get_viewport().get_camera_3d()

func _process(delta):
	if camera:
		# Make the label look at the camera
		look_at(camera.global_transform.origin, Vector3.UP)
		# Correct for flipping
		rotate_y(deg_to_rad(180))
		# Keep label upright
		rotation.x = 0
		rotation.z = 0
