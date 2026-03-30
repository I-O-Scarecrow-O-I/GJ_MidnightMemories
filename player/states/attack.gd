class_name PlayerStateAttack
extends PlayerState

@export var attack_duration: float = 0.18
var _timer: float = 0.0

func enter() -> void:
	_timer = attack_duration
	player.start_attack()

func exit() -> void:
	player.end_attack()

func handle_input(_event: InputEvent) -> PlayerState:
	return next_state

func process(delta: float) -> PlayerState:
	_timer -= delta
	if _timer <= 0.0:
		if player.is_on_ladder:
			return climb
		if not player.is_on_floor():
			return fall
		if player.direction.x != 0:
			return run
		return idle
	return next_state
