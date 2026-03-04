class_name DamageSystem

static func apply_damage(target: Node, amount: float, source: Node) -> void:
	var damageable = target.find_child("Damageable", true, false)
	if damageable:
		damageable.take_damage(amount, source)
