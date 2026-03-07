extends Node3D

@onready var viewport = $SubViewport

func _input(event):
	if event.is_action_pressed("ui_accept"): # Press Spacebar/Enter to capture
		capture_now()

func capture_now():
	# 1. Force the viewport to render right now
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# 2. Wait for the GPU to actually finish the draw call
	await RenderingServer.frame_post_draw
	
	# 3. Get the texture
	var tex = viewport.get_texture()
	var img = tex.get_image()
	
	if img == null or img.is_empty():
		print("Error: The image is still null or empty!")
		return

	# 4. Fix the upside-down orientation
	
	# 5. Save to a path that definitely exists
	var path = "res://ressources/pictures/lantern.png"
	var err = img.save_png(path)
	
	if err == OK:
		print("SUCCESS! Saved to: ", ProjectSettings.globalize_path(path))
	else:
		print("Save failed with error code: ", err)
