extends Node

var day_count: int = 1
var gravity: float = 9.8

var won: bool = false

var paused: bool = false

func reset_day() -> void:
	day_count = 1

func advance_day() -> void:
	day_count += 1
