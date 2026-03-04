extends StaticBody3D

@export var damage: float = 30.0
@export var damage_interval: float = 0.5  # seconds between damage ticks

@onready var damageable: Node = $Components/Damageable
@onready var loot_table: Node = $Components/LootTable

# Keeps track of bodies currently inside the area
var bodies_inside := {}

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	damageable.died.connect(_on_died)

func _on_died() -> void:
	loot_table.calculate_loot()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("damagable_by_spikes"):
		DamageSystem.apply_damage(body, damage, self)
		bodies_inside[body] = 0.0  # start timer for interval damage

func _on_body_exited(body: Node3D) -> void:
	bodies_inside.erase(body)

func take_damage(damage: float) -> void:
	damageable.take_damage(damage)

func _physics_process(delta: float) -> void:
	# Loop through bodies inside the spike area
	for body in bodies_inside.keys():
		bodies_inside[body] += delta
		if bodies_inside[body] >= damage_interval:
			body.take_damage_from_spike(damage)
			bodies_inside[body] = 0.0
