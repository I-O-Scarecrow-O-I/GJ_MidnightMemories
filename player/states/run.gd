class_name PlayerStateRun extends PlayerState

func init()-> void:
	pass

func enter()->void:
	#player animation
	
	pass
	
func exit()->void:
	
	pass

func handle_input(_event:InputEvent)->PlayerState:
	if _event.is_action_pressed("jump"):
		return jump
	if _event.is_action_pressed("attack"):
		return attack
	return next_state 

func process(_delta: float) -> PlayerState:
	if player.direction.x==0:
		return idle
	if player.is_in_ladder_area and Input.is_action_pressed("up"):
		return climb
	return next_state
	

func physics_process(delta: float) -> PlayerState:
	player.velocity.x=player.direction.x*player.move_speed
	if player.is_on_floor()==false:
		return fall
	return next_state
