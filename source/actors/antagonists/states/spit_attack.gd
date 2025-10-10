class_name SpitAttackState
extends State


func _ready() -> void:
	pass


func enter(_params: Dictionary) -> void:
	character.set_velocity(Vector3.ZERO)
	character.animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	character.blend_to_new_anim("Walk") # For after the spit attack ends, don't want to blend from run to walk
	await get_tree().create_timer(2.0, false).timeout
	transitioned.emit(self, "ChasePause")


func exit() -> void:
	pass
