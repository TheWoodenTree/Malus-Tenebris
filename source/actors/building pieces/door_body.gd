extends RigidBody3D


func _on_body_entered(body):
	if body == Global.player:
		angular_velocity = Vector3.ZERO
