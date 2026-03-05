extends Node

var day_count: int = 1
var gravity: float = 9.8

func reset_day() -> void:
	day_count = 0

func advance_day() -> void:
	day_count += 1
