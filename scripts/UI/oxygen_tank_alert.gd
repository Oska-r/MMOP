extends RichTextLabel

@onready var oxygen_tank = get_tree().get_first_node_in_group("oxygen_tank")
@onready var hide_timer: Timer = $HideTimer

func _ready() -> void:
	bbcode_enabled = true
	text = "[color=#ff0000]Der Sauerstofftank nimmt Schaden![/color]"
	hide()

	if oxygen_tank and oxygen_tank.has_node("Components/Damageable"):
		oxygen_tank.get_node("Components/Damageable").took_damage.connect(oxygen_tank_took_damage)

	# Connect timer timeout
	hide_timer.timeout.connect(_on_hide_timer_timeout)

func oxygen_tank_took_damage(damage: int, source: Node) -> void:
	show()
	# Restart timer to always wait 3 seconds from last damage
	hide_timer.stop()
	hide_timer.start()

func _on_hide_timer_timeout() -> void:
	hide()
