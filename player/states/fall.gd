class_name PlayerStateFall extends PlayerState

func init()-> void:
	pass

func enter()->void:
	#playerAnimation
	pass
	
func exit()->void:
	
	pass

func handle_input(_event:InputEvent)->PlayerState:
	return next_state

func process(_delta: float) -> PlayerState:  
	return next_state
	

func physics_process(delta: float) -> PlayerState:
	if player.is_on_floor():
		player.add_debug_indicator(Color.RED)
		return idle
	player.velocity.x=player.direction.x*player.move_speed
	return next_state
