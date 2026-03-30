class_name PlayerStateClimb extends PlayerState

@export var climb_speed: float = 100.0

func init() -> void:
	pass

func enter() -> void:
	player.is_on_ladder = true
	player.velocity = Vector2.ZERO

func exit() -> void:
	player.is_on_ladder = false

func handle_input(_event: InputEvent) -> PlayerState:
	if _event.is_action_pressed("jump"):
		return jump
	return next_state

func process(_delta: float) -> PlayerState:
	if not player.is_in_ladder_area:
		return fall
	return next_state

func physics_process(_delta: float) -> PlayerState:
	var y_axis = Input.get_axis("up", "down")
	player.velocity.y = y_axis * climb_speed
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
