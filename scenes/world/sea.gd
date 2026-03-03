extends StaticBody3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body, " entered")
	if body.is_in_group("player"):
		body.die()
