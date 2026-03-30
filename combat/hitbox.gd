class_name HitBox extends Area2D

@export var damage: int = 1
@export var knockback: float = 240.0

@export var debug_visible_when_active: bool = true
@onready var debug_rect: ColorRect = get_node_or_null("DebugRect") as ColorRect

func _ready() -> void:
	set_active(false)
	_update_debug()

func set_active(v: bool) -> void:
	monitoring = v
	monitorable = v
	_update_debug()

func _update_debug() -> void:
	if debug_rect == null:
		return
	debug_rect.visible = debug_visible_when_active and monitoring
