extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_number: Label = $HealthBar/HealthNumber

func player_health_changed(current_health: float, max_health: float) -> void:
	health_bar.value = current_health
	health_bar.max_value = max_health
	health_number.text = str(int(current_health)) + " / " + str(int(max_health))
