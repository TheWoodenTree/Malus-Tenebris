class_name SpitAttackState
extends State


func _ready() -> void:
	pass


func enter(_params: Dictionary) -> void:
	character.set_velocity(Vector3.ZERO)
	character.animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(0.833, false).timeout
	transitioned.emit(self, "Chase")



func exit() -> void:
	pass
