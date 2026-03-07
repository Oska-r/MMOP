extends Timer

@export var max_wait_time: float = 5.0
@export var min_wait_time: float = 1.0

@export var timer_decay_rate: float = 0.15

func calculate_wait_time(day_count: int) -> void:
	wait_time = FunctionHelper.logistic_growth(max_wait_time, min_wait_time, timer_decay_rate, day_count)
