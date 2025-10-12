class_name InvestigateState
extends NPCState

const PARAM_INVESTIGATE_POSITION = "investigate_position"

@export var move_speed := 4.5


func _ready() -> void:
	pass


func enter(params: Dictionary) -> void:
	nav_agent.target_position = params[PARAM_INVESTIGATE_POSITION]


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
	
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = character.global_position.direction_to(next_pos)
	
	character.velocity = direction.normalized() * move_speed
	
	character.check_for_door_in_path()
	
	if nav_agent.is_target_reached():
		transitioned.emit(self, 'Wander')
