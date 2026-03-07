extends Node

func logistic_growth(start_value: float, max_value: float, growth_rate: float, x_value: float) -> float:
	var x_offset: float = 4.0 # The "peak" of the curve's steepness
	var x_start: float = 1.0
	
	# 1. Calculate the raw logistic value at our starting X (to "zero" it out)
	var logistic_at_start = 1.0 / (1.0 + exp(-growth_rate * (x_start - x_offset)))
	
	# 2. Calculate the raw logistic value at the current X
	var logistic_current = 1.0 / (1.0 + exp(-growth_rate * (x_value - x_offset)))
	
	# 3. Normalize: (current - start) / (1.0 - start) 
	# This ensures the multiplier goes from 0.0 at x=1 to 1.0 at x=infinity
	var normalized = (logistic_current - logistic_at_start) / (1.0 - logistic_at_start)
	
	# Clamp it so it doesn't go below 0 if x_value is less than 1
	normalized = max(0.0, normalized)
	
	return start_value + (max_value - start_value) * normalized
