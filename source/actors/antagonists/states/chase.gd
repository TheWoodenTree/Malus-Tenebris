class_name ChaseState
extends State

const PARAM_PLAY_SOUND = "play_sound"

const PATH_UPDATE_INTERVAL := 0.15

@export var move_speed := 7.0

var time_since_last_update := 0.0


func _ready() -> void:
	pass


func enter(params: Dictionary) -> void:
	character.suspicion = 1.0
	character.blend_to_new_anim("Run")
	
	if params.has(PARAM_PLAY_SOUND) and not params[PARAM_PLAY_SOUND]:
		return
	
	Global.main.set_fear_enabled(true)
	character.sound_player.play()


func exit() -> void:
	pass


func physics_update(delta: float):
	time_since_last_update += delta
	var can_see_player: bool = character.can_see_player()
	if can_see_player:
		character.awareness = 1.0
	else:
		character.awareness -= delta * 0.5
	
	if can_see_player or not character.is_min_awareness():
		character.suspicion += delta * 4.0
		
		if time_since_last_update >= PATH_UPDATE_INTERVAL:
			time_since_last_update = 0.0
			nav_agent.target_position = Global.player.global_position
	else:
		character.suspicion -= delta * 0.1333
		if character.is_min_suspicion():
			transitioned.emit(self, 'Wander')
			Global.main.set_fear_enabled(false)
	
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = character.global_position.direction_to(next_pos)
	
	character.velocity = direction.normalized() * move_speed
	
	if character.is_near_door():
		character.check_for_door_in_path()
	
	if character.global_position.distance_to(Global.player.global_position) < 3.0 and character.player_in_fov(30):
		transitioned.emit(self, 'SpitAttack')
