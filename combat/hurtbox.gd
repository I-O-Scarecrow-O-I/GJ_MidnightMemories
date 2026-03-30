class_name HurtBox extends Area2D

signal hit_received(hitbox: HitBox)

@export var invincible: bool = false

func _ready() -> void:
	monitorable = true
	monitoring = true
	area_entered.connect(_on_area_entered)

func _on_area_entered(a: Area2D) -> void:
	if invincible:
		return
	if a is HitBox:
		emit_signal("hit_received", a)
