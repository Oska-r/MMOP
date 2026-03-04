extends CharacterBody3D

@onready var head: Node = get_node("Head")
@onready var interact_ray: RayCast3D = head.get_node("Camera3D/InteractRay")
@onready var place_ray: RayCast3D = $Head/Camera3D/PlaceRay
@onready var attack_Area: Area3D = head.get_node("Attack_Area")
@onready var UI: Control = get_parent().get_node("UI")
@onready var inventory: Control = UI.get_node("Inventory")
@onready var damageable: Node = $Components/Damageable
@onready var attack_timer: Timer = $AttackTimer
@onready var oxygen_tank = get_tree().get_first_node_in_group("Oxygentank")

var dead: bool = false
var mouse_captured: bool = false
var input_enabled: bool = true

var place_reach: float = 4.0
var item_use_cooldown: float = 0.0
var item_use_delay: float = 0.15

## list of all bodys in Attack_Area
var targets: Array[Node3D]

# attributes
@export_category("Attributes")
@export var damage: float =  30.0
@export var attack_interval: float = 0.25
var damage_timer: float = 0.0

signal player_health_changed(current_health: float, max_health: float)

func _ready() -> void:
	attack_Area.visible = false
	damageable.died.connect(_on_died)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	emit_signal("player_health_changed", get_health(), get_max_health())

var looking_at_tank: bool = false  # track previous frame

func _process(delta) -> void:
	if dead:
		return
	
	if item_use_cooldown > 0:
		item_use_cooldown -= delta
	if damage_timer > 0:
		damage_timer -= delta
	if Input.is_action_pressed("prime"):
		handle_attack()
	
	# Check if the interact ray is hitting something
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		
		if collider == oxygen_tank:
			if not looking_at_tank:
				oxygen_tank.display_requirements(true)
				looking_at_tank = true
		else:
			# player looked at something else
			if looking_at_tank:
				oxygen_tank.display_requirements(false)
				looking_at_tank = false
	else:
		# player looked at nothing
		if looking_at_tank:
			oxygen_tank.display_requirements(false)
			looking_at_tank = false

func drop(item: Item_ids.ItemID) -> void:
	inventory.drop(item)

## Checks wether and with what the interaction ray is colliding with.
func check_interaction() -> void:
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		
		# Check if the object we hit has the toggle_chest function
		if collider.has_method("toggle_chest"):
			collider.toggle_chest()
		if collider.has_method("toggle_crafting_table"):
			collider.toggle_crafting_table()
		if collider.has_method("toggle_furnace"):
			collider.toggle_furnace()

#region input
func _input(event) -> void:
	if event.is_action_pressed("interact"):
		check_interaction()
	if event.is_action_pressed("interact_e"):
		if not interact_ray.is_colliding():
			return
		var collider = interact_ray.get_collider()
		if collider.has_method("try_craft_current_tier"):
				collider.try_craft_current_tier()

## Disables (if parameter is false) or enables (if parameter is true) all player input (used for openend UIs).
func enable_input(enable: bool) -> void:
	input_enabled = enable
	
	set_process(enable)
	set_physics_process(enable)
	set_process_input(enable)
	set_process_unhandled_input(enable)
	
	if enable:
		capture_mouse()
	else:
		release_mouse()

## Caputres the mouse so the player can look around again.
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

## Releases the mouse so the player can interact with menus.
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func is_input_enabled() -> bool:
	return input_enabled

#endregion

#region placing blocks
## Calculates the position of where to spawn the block the player wants to place.
func calculate_block_spawn_pos() -> Vector3:
	if not place_ray.is_colliding():
		return Vector3.ZERO
	
	var collider = place_ray.get_collider()
	
	# Only allow placement if the hit object is in the "floor" group
	if not collider.is_in_group("placable_surface"):
		return Vector3.ZERO
	
	
	var hit_position = place_ray.get_collision_point()
	
	# Start slightly above the hit point
	var from = hit_position + Vector3.UP * 2.0
	var to = hit_position + Vector3.DOWN * 10.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	
	return Vector3.ZERO

## Returns the blocks_root node (node used for storing all placed blocks).
func get_blocks_root(create_if_missing := false) -> Node3D:
	var blocks_root := get_tree().current_scene.get_node_or_null(
		"World/World_flexible/Blocks"
	) as Node3D
	
	if blocks_root == null and create_if_missing:
		var parent := get_tree().current_scene.get_node(
			"WorldWorld_flexible"
		) as Node3D
		
		blocks_root = Node3D.new()
		blocks_root.name = "Blocks"
		parent.add_child(blocks_root)
	
	return blocks_root

## Places (if possible) item/block in direction of looking.
func place_block(item) -> bool:
	var blocks_root = get_blocks_root(true)
	var spawn_pos = calculate_block_spawn_pos()
	
	if not spawn_pos:
		return false
	
	Global.play_sound(item.sound)
	
	var instance = item.scene.instantiate()
	blocks_root.add_child(instance)
	instance.global_transform.origin = spawn_pos
	
	Global.rotate(instance, 270)
	
	# Force update the preview immediately so it doesn't show inside the new block
	clear_preview()
	return true

var last_preview: Node3D = null

## Clears the last preview item.
func clear_preview() -> void:
	if last_preview:
		last_preview.queue_free()
		last_preview = null

## Updates the preview hologram
func show_preview(item) -> void:
	var spawn_pos = calculate_block_spawn_pos()
	
	if not spawn_pos:
		clear_preview()
		return
	
	# If no preview exists or item changed, create a new one
	if not last_preview: # Simplified check; we usually queue_free on item switch anyway
		var instance = item.scene.instantiate() as Node3D
		
		get_tree().current_scene.add_child(instance)
		instance.global_transform.origin = spawn_pos
	
		# Apply transparency
		apply_transparency(instance)
		last_preview = instance
		
		disable_collision_recursively(instance)
	
	else:
		# Preview exists, just move it
		last_preview.global_transform.origin = spawn_pos
	
	Global.rotate(last_preview, 270)

## Disables all collision from all children.
func disable_collision_recursively(node: Node) -> void:
	if node is CollisionShape3D or node is CollisionPolygon3D:
		node.disabled = true
	for child in node.get_children():
		disable_collision_recursively(child)

## Applies lower transparency to given node (used for displaying more transparent previews blocks).
func apply_transparency(node: Node, alpha: float = 0.5) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh = child.mesh
			if mesh:
				for i in range(mesh.get_surface_count()):
					var mat: StandardMaterial3D = child.get_active_material(i)
					if mat:
						mat = mat.duplicate() as StandardMaterial3D
						child.set_surface_override_material(i, mat)
						mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
						mat.flags_transparent = true
						var color = mat.albedo_color
						color.a = alpha
						mat.albedo_color = color
		
		if child is CollisionShape3D:
			child.disabled = true
		
		# Recursive call for nested children
		if child is Node3D:
			apply_transparency(child, alpha)

#endregion

#region using items
## Uses item if use is not on cooldown.
func try_to_use_item(item) -> bool:
	if item_use_cooldown <= 0:
		item_use_cooldown = item_use_delay
		return use_selected_item(item)
	return false

## Places item if placable, otherwise returns false.
func use_selected_item(item) -> bool:
	if item.scene:
		return place_block(item)
	return false
#endregion

#region damage

func handle_attack() -> void:
	if damage_timer > 0:
		return
	targets = attack_Area.get_overlapping_bodies()
	
	for body in targets:
		if body.is_in_group("damagable_by_player"):
			body.take_damage(damage)
			damage_timer = attack_interval
			attack_animation()

func attack_animation() -> void:
	if not is_inside_tree():
		return
	
	attack_Area.visible = true
	attack_timer.start()

func take_damage(damage: int) -> void:
	damageable.take_damage(damage)
	emit_signal("player_health_changed", get_health(), get_max_health())

func _on_attack_timer_timeout():
	if is_instance_valid(attack_Area):
		attack_Area.visible = false

func _on_died() -> void:
	dead = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Use call_deferred to delay the scene change
	call_deferred("_change_to_end_screen")

func _change_to_end_screen() -> void:
	get_viewport().get_tree().change_scene_to_file("res://scenes/UI/menus/end_screen.tscn")

func die() -> void:
	damageable.die()

#endregion

#region getter_and_stter
func get_max_health() -> float:
	return damageable.max_health

func get_health() -> float:
	return damageable.health
#endregion
