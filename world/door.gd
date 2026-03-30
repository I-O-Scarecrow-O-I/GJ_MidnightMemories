class_name Door
extends StaticBody2D

@export var locked: bool = true

@onready var _shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_apply_locked_deferred()

func unlock() -> void:
	locked = false
	_apply_locked_deferred()

func lock() -> void:
	locked = true
	_apply_locked_deferred()

func _apply_locked_deferred() -> void:
	if not _shape:
		return
	# 解锁 => disabled = true（不阻挡）
	_shape.set_deferred("disabled", locked == false)
