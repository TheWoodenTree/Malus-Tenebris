class_name PlayerCrouchIdleState
extends State


func enter(_params: Dictionary):
	character.moving = false
	
	if not character.crouching:
		character.start_crouch_transition(true)
	
	character.crouching = true


func exit():
	pass


func physics_update(_delta: float):
	if character.in_menu or character.scripted_event:
		return
		
	if not Input.is_action_pressed("crouch") and not character.is_crouch_tween_active() and character.can_stand():
		if not is_zero_approx(character.input_dir.length()):
			if not Input.is_action_pressed("sprint"):
				transitioned.emit(self, "PlayerWalk")
			else:
				transitioned.emit(self, "PlayerSprint")
		else:
			transitioned.emit(self, "PlayerIdle")
		character.crouching = false
		character.start_crouch_transition(false)
	elif not is_zero_approx(character.input_dir.length()):
		transitioned.emit(self, "PlayerCrouchWalk")
