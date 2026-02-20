extends CharacterBody3D

@onready var head: Node = get_node("Head")
@onready var interact_ray: RayCast3D = head.get_node("Camera3D/InteractRay")
@onready var attack_Area: Area3D = head.get_node("Attack_Area")
@onready var inventory: Control = get_parent().get_node("UI").get_node("Inventory")
var mouse_captured: bool = false
var input_enabled: bool = true

var place_reach: float = 2.7
var item_use_cooldown: float = 0.0
var item_use_delay: float = 0.15

## list of all bodys in Attack_Area
var targets: Array[Node3D]

# attributes
@export_category("attributes")
@export var health_max: float = 100.0
@export var damage: float =  30.0
@export var attack_interval: float = 0.25
var damage_timer: float = 0.0
var health: float = health_max

func _ready() -> void:
		attack_Area.visible = false

func _input(event) -> void:
	if event.is_action_pressed("interact"):
		check_interaction()

func _process(delta) -> void:
	if item_use_cooldown > 0:
		item_use_cooldown -= delta
	if damage_timer > 0:
		damage_timer -= delta
	if Input.is_action_pressed("prime"):
		handle_attack()

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

#region placing blocks
## Calculates the position of where to spawn the block the player wants to place.
func calculate_block_spawn_pos(blocks_root: Node) -> Vector3:
	var look_dir = -head.global_transform.basis.z.normalized()
	var target = (head.global_transform.origin + look_dir * place_reach).snapped(Vector3.ONE)
	
	for block in blocks_root.get_children():
		if block.global_position.is_equal_approx(target):
			return target + Vector3.UP
	
	return target

## Returns true if the block has a supporting block beneath it or is on the ground.
func block_placeable(spawn_pos: Vector3, blocks_root: Node3D = null) -> bool:
	# 1. Prevent placing below or at ground level
	if spawn_pos.y <= 0:
		return false
	
	# 2. If blocks_root is null, we can't check neighbors, so we assume strictly false 
	if blocks_root == null:
		return false 
	
	# prevent the player from stacking up
	for i in range(place_reach):
		if spawn_pos.is_equal_approx(global_position.snapped(Vector3.ONE) + (i * Vector3.DOWN)):
			return false
	
	var has_support = false
	
	# If it's on the first layer (y=1), it's supported by the floor.
	if spawn_pos.y == 1:
		has_support = true
	
	
	for child in blocks_root.get_children():
		if spawn_pos.is_equal_approx(child.global_position + Vector3.UP):
			has_support = true
			break
	
	return has_support

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
	var spawn_pos = calculate_block_spawn_pos(blocks_root)
	
	if not block_placeable(spawn_pos, blocks_root):
		return false
	
	Global.play_sound(item.sound)
	var instance = item.scene.instantiate()
	blocks_root.add_child(instance)
	instance.global_transform.origin = spawn_pos
	
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
	var blocks_root = get_blocks_root(false) # Don't create if missing, just get it
	var spawn_pos = calculate_block_spawn_pos(blocks_root)
	
	if not block_placeable(spawn_pos, blocks_root):
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
		
		# Verify name matches (in case you swapped items fast)
		if last_preview.name != item.scene.resource_name:
			# If names don't match logic (optional), you might want to rebuild
			pass

## Disables all collision from all children.
func disable_collision_recursively(node: Node) -> void:
	if node is CollisionShape3D or node is CollisionPolygon3D:
		node.disabled = true
	for child in node.get_children():
		disable_collision_recursively(child)

## Applies lower transparency to given node (used for displaying more transparent previews blocks).
func apply_transparency(node: Node, alpha: float = 0.5) -> void:
	if node is MeshInstance3D:
		var mat: StandardMaterial3D = node.get_active_material(0)
		if mat:
			mat = mat.duplicate() as StandardMaterial3D
			node.set_surface_override_material(0, mat)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.flags_transparent = true
			var color = mat.albedo_color
			color.a = alpha
			mat.albedo_color = color

	if node is CollisionShape3D:
		node.disabled = true

	for child in node.get_children():
		if child is Node3D:
			apply_transparency(child, alpha)
#endregion

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

func is_input_enabled() -> bool:
	return input_enabled

#region damage

func handle_attack() -> void:
	if damage_timer > 0:
		return
	targets = attack_Area.get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("enemy"):
			body.take_damage(damage)
			damage_timer = attack_interval
			attack_animation()

func attack_animation() -> void:
	attack_Area.visible = true
	await get_tree().create_timer(0.2).timeout
	attack_Area.visible = false

func take_damage(amount: int) -> void:
	health -= amount
	print("Spieler bekommt Schaden! Leben:", health)

	if health <= 0:
		call_deferred("die")

func die() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/UI/menus/end_screen.tscn")

#endregion
