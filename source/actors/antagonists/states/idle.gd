class_name IdleState
extends State


func _ready() -> void:
	pass


func enter(_params: Dictionary) -> void:
	character.blend_to_new_anim("Idle")


func exit() -> void:
	pass


func physics_update(delta: float):
	if character.can_see_player(30.0):
		var norm_distance: float = clamp(character.global_position.distance_to(Global.player.global_position) / 30.0, 0.0, 1.0)
		var delta_scale: float = 1.0 - pow(norm_distance, 3.0)
		character.suspicion += delta * (delta_scale)
		if character.is_max_suspicion():
			transitioned.emit(self, 'Chase')
	else:
		character.suspicion = 0.0
