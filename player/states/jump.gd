class_name PlayerStateJump extends PlayerState

@export var jump_velocity:float=450.0

func init()-> void:
	pass

func enter()->void:
	#playerAnimation
	player.add_debug_indicator(Color.LIME_GREEN)
	player.velocity.y=-jump_velocity
	pass
	
func exit()->void:
	player.add_debug_indicator(Color.YELLOW)
	pass


func process(_delta: float) -> PlayerState:
	return next_state
	
func handle_input(event:InputEvent)->PlayerState:
	if event.is_action_released("jump"):
		player.velocity.y*=0.5
	if event.is_action_pressed("attack"):
		return attack
	return next_state
	

func physics_process(delta: float) -> PlayerState:
	if player.is_on_floor():
		print("on floor")
		return idle
	elif player.velocity.y>=0:
		return fall
	if player.is_in_ladder_area:
		return climb
	player.velocity.x=player.direction.x*player.move_speed
	return next_state
