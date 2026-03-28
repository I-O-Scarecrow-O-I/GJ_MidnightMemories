class_name PlayerStateFall extends PlayerState

@export var coyote_time:float=0.125
var coyote_timer:float=0

func init()-> void:
	pass

func enter()->void:
	#playerAnimation
	if player.previous_state==jump:
		coyote_timer=0
	else:
		coyote_timer=coyote_time
	pass
	
func exit()->void:
	
	pass

func handle_input(event:InputEvent)->PlayerState:
	if event.is_action_pressed("jump") and coyote_timer>0:
		return jump
	return next_state

func process(delta: float) -> PlayerState:  
	coyote_timer-=delta
	return next_state
	

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		player.add_debug_indicator(Color.RED)
		return idle
	player.velocity.x=player.direction.x*player.move_speed
	return next_state
