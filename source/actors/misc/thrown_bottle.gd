extends RigidBody3D

var collision_normal: Vector3 = Vector3.ZERO

var break_effect_res: Resource = preload("res://source/assets/particles/ruboleum_vial_break.tscn")

@onready var break_player = $break_player


func _integrate_forces(state: PhysicsDirectBodyState3D):
	if get_contact_count() > 0:
		collision_normal = state.get_contact_local_normal(0)


func _on_body_entered(_body):
	var break_effect: Node3D = break_effect_res.instantiate()
	Global.world.add_child(break_effect)
	break_effect.global_position = global_position
	break_effect.relative_up_direction = collision_normal
	break_effect.play()
	queue_free()
