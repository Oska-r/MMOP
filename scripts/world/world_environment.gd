extends WorldEnvironment

signal day_started(day_count: int)

@export_category("Time")
@export var day_length_seconds: float = 180.0
## 0 morning | 0.25 noon | 0.75 midnight 
@export var time: float = 0.0
var is_day: bool

@export_category("Sun")
@export var sun_max_intensity: float = 1.0
@export var sun_color: Color = Color(1, 1, 0.9)
@export var sun_pivot: Node3D
@onready var sun_light: DirectionalLight3D = sun_pivot.get_node("SunLight")

@export_category("Moon")
@export var moon_max_intensity: float = 0.05
@export var moon_color: Color = Color(0.6, 0.7, 1)
@export var moon_pivot: Node3D
@onready var moon_light: DirectionalLight3D =  moon_pivot.get_node("MoonLight")

func _ready() -> void:
	day_started.emit()
	moon_light.light_color = moon_color

func _process(delta) -> void:
	time += delta / day_length_seconds
	if time > 1.0:
		time -= 1.0
		GlobalGameState.advance_day()
		day_started.emit()
	
	_update_lights()

# Handles day night cycle.
func _update_lights() -> void:
	# Rotates sun and moon
	sun_pivot.rotation_degrees.x = - lerp(0,360,time)
	moon_pivot.rotation_degrees.x = sun_pivot.rotation_degrees.x - 180
	# Sun height factor: 0 = below horizon, 1 = overhead
	var sun_height_factor = - sin(deg_to_rad(sun_pivot.rotation_degrees.x))
	
	# Sun intensity
	sun_light.light_energy = sun_max_intensity * sun_height_factor
	
	# Moon intensity: stronger at night, weaker when sun is up, complementary to sun
	var moon_height_factor = 1.0 - sun_height_factor
	moon_light.light_energy = moon_max_intensity * moon_height_factor
	
	# Sunrise/sunset color for sun
	var sunrise_color = Color(1, 0.7, 0.5)
	sun_light.light_color = sun_color.lerp(sunrise_color, 1 - sun_height_factor)
	is_day = sun_height_factor > 0
