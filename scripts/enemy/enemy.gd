extends CharacterBody3D
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var damage_area: Area3D = $Damage_Area
@onready var player = get_tree().get_first_node_in_group("player")

@export var speed: float = 3.0
@export var damage: float = 10.0
@export var damage_interval: float = 1.0

@onready var damageable: Node = $Components/Damageable
@onready var loot_table: Node = $Components/LootTable

@onready var health_label: Label3D = $HealthLabel

# Damage
var damage_timer: float= 0.0
var bodies_in_damage_area: Array[Node3D] = []
var player_can_take_damage: bool = true

# Movement
var player_position : Vector3
var oxygentank_position : Vector3

func _ready() -> void:
	randomize() # So that numbers between different executes are random.
	add_to_group("enemy")
	oxygentank_position = get_tree().get_first_node_in_group("Oxygentank").global_position
	damageable.died.connect(_on_died)
	damageable.took_damage.connect(_took_damage)
	Global.update_health_display(health_label, damageable)

func _physics_process(delta) -> void:
	apply_gravity(delta)
	update_movement()
	handle_damage()
	move_and_slide()
	
	if damage_timer >= 0:
		damage_timer -= delta

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Global.gravity * delta
	else:
		velocity.y = 0

## moves the enemey towards the target along the navigationmap
func update_movement() -> void:
	if player == null:
		velocity.x = 0
		velocity.z = 0
		return
	
	agent.target_position = find_target()
	
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

## returns the "best target"
func find_target():
	player_position = player.global_position
	var oxygen_distance = global_position.distance_to(oxygentank_position)
	var player_distance = global_position.distance_to(player_position)
	
	if oxygen_distance < player_distance:
		return oxygentank_position
	else:
		return player_position

## Delete node and drop loot.
func _on_died() -> void:
	if not died_from_sun:
		loot_table.calculate_loot()

var died_from_sun: bool = false

func sun_damage(amount: float) -> void:
	died_from_sun = true
	damageable.take_damage(amount)

func take_damage(damage: float) -> void:
	died_from_sun = false
	damageable.take_damage(damage)

# Put updating label here to avoid redundancy
func _took_damage(damage: int) -> void:
	Global.update_health_display(health_label, damageable)

# This function is called from the main scene.
func initialize(start_position) -> void:
	look_at_from_position(start_position, Vector3(0,0,0))

func _on_body_entered(body) -> void:
	if body is PhysicsBody3D:
		bodies_in_damage_area.append(body)

func _on_body_exited(body) -> void:
	if body is PhysicsBody3D:
		bodies_in_damage_area.erase(body)
