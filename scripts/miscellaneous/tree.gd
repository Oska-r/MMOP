extends StaticBody3D

var health: int = 500

func take_damage(damage: int) -> void:
	health -= damage
	if health < 0:
		die()
	print("Health: ")

func die() -> void:
	print("Tree dead")
	queue_free()
