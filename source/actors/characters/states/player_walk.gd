class_name PlayerWalkState
extends State


func enter(_params: Dictionary):
	character.moving = true
	character.max_speed = character.walk_speed
	character.footstep_timer.wait_time = character.footstep_walk_interval / character.speed_multiplier


func exit():
	pass


func physics_update(_delta: float):
	if character.in_menu or character.scripted_event:
		return
		
	if not is_zero_approx(character.input_dir.length()):
		if Input.is_action_just_pressed("crouch") and not character.is_crouch_tween_active():
			transitioned.emit(self, "PlayerCrouchWalk")
		elif Input.is_action_just_pressed("sprint"):
			transitioned.emit(self, "PlayerSprint")
	else:
		if Input.is_action_just_pressed("crouch") and not character.is_crouch_tween_active():
			transitioned.emit(self, "PlayerCrouchIdle")
		else:
			transitioned.emit(self, "PlayerIdle")
			
	if character.footstep_timer.time_left > character.footstep_walk_interval / character.speed_multiplier:
		character.footstep_timer.start(character.footstep_walk_interval)
