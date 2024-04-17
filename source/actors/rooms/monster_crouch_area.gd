extends Area3D


func _on_body_entered(body):
	if body == Global.monster:
		if Global.monster.crouching:
			Global.monster.uncrouch()
		else:
			Global.monster.crouch()
