class_name Health
extends Node

signal died
signal changed(current: int, max_value: int)

@export var max_health: int = 5
var current_health: int

func _ready() -> void:
	current_health = max_health
	emit_signal("changed", current_health, max_health)

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	emit_signal("changed", current_health, max_health)
	if current_health == 0:
		emit_signal("died")
