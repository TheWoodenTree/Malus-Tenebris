class_name PlayerIdleState
extends State


func enter(_params: Dictionary):
	character.moving = false


func exit():
	pass


func physics_update(_delta: float):
	if character.in_menu or character.scripted_event:
		return
		
	if not is_zero_approx(character.input_dir.length()):
		if Input.is_action_pressed("sprint"):
			transitioned.emit(self, "PlayerSprint")
		else:
			transitioned.emit(self, "PlayerWalk")
	elif Input.is_action_just_pressed("crouch") and not character.is_crouch_tween_active():
		if is_zero_approx(character.input_dir.length()):
			transitioned.emit(self, "PlayerCrouchIdle")
		else:
			transitioned.emit(self, "PlayerCrouchWalk")
