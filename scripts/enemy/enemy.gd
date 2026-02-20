extends CharacterBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var damage_area: Area3D = $Damage_Area
@onready var player = get_tree().get_first_node_in_group("player")

@export var speed: float = 3.0
@export var damage: float = 10.0
@export var gravity: float = 9.8
@export var damage_interval: float = 1.0
@export var health: float = 30.0

var damage_timer: float= 0.0
var bodies_in_damage_area: Array[Node3D] = []
var player_can_take_damage: bool = true

var loot_table: Dictionary = {Item_ids.ItemID.OIL: 0.1}

func _ready() -> void:
	randomize() # So that numbers between different executes are random.
	add_to_group("enemy")

func _physics_process(delta) -> void:
	apply_gravity(delta)
	update_movement()
	handle_damage()
	move_and_slide()
	
	if damage_timer >= 0:
		damage_timer -= delta

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

## Sets velocity to 0.
func update_movement() -> void:
	if player == null:
		velocity.x = 0
		velocity.z = 0
		return

	agent.target_position = player.global_position

	if agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return

	var next_pos = agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

## attackes everything with take_damage funktion
## dosn't attack other enemys
func handle_damage() -> void:
	if damage_timer > 0:
		return
	for body in bodies_in_damage_area:
		# don't apply damage to other enemys
		if body.is_in_group("enemy"):
			pass
		elif body != null and body.has_method("take_damage"):
			body.take_damage(damage)
			damage_timer = damage_interval

func take_damage(amount, from_sun: bool = false) -> void:
	health -= amount
	if health <= 0:
		die(from_sun)

## Delete node and drop loot.
func die(from_sun: bool = false) -> void:
	if not from_sun:
		var roll := randf()
		for item in loot_table:
			if roll <= loot_table[item]:
				player.drop(item)
	
	queue_free()

func sun_damage(amount) -> void:
	take_damage(amount, true)

# This function will be called from the Main scene.
func initialize(start_position) -> void:
	look_at_from_position(start_position, Vector3(0,0,0))

func _on_body_entered(body) -> void:
	if body is PhysicsBody3D:
		bodies_in_damage_area.append(body)

func _on_body_exited(body) -> void:
	if body is PhysicsBody3D:
		bodies_in_damage_area.erase(body)
