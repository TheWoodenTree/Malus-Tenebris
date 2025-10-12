class_name PlayerSprintState
extends State


func enter(_params: Dictionary):
	character.moving = true
	character.sprinting = true
	character.max_speed = character.sprint_speed
	character.footstep_timer.wait_time = character.footstep_sprint_interval / character.speed_multiplier


func exit():
	character.sprinting = false


func physics_update(_delta: float):
	if character.in_menu or character.scripted_event:
		return
		
	if not Input.is_action_pressed("sprint"):
		if not is_zero_approx(character.input_dir.length()):
			transitioned.emit(self, "PlayerWalk")
		else:
			transitioned.emit(self, "PlayerIdle")
	elif Input.is_action_just_pressed("crouch") and not character.is_crouch_tween_active():
		if not is_zero_approx(character.input_dir.length()):
			transitioned.emit(self, "PlayerCrouchWalk")
		else:
			transitioned.emit(self, "PlayerCrouchIdle")
	
	if character.footstep_timer.time_left > character.footstep_sprint_interval / character.speed_multiplier:
		character.footstep_timer.start(character.footstep_sprint_interval)
