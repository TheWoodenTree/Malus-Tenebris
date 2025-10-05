class_name Chase
extends State

const PATH_UPDATE_INTERVAL := 0.15

@export var move_speed := 6.5

var time_since_last_update := 0.0


func _ready() -> void:
	pass


func enter(_params: Dictionary) -> void:
	character.suspicion = 1.0
	Global.main.set_fear_enabled(true)
	character.get_node("AnimationPlayer2").speed_scale = 2.1


func exit() -> void:
	Global.main.set_fear_enabled(false)


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
		character.suspicion -= delta * 0.1
		if character.is_min_suspicion():
			transitioned.emit(self, 'Wander')
	
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = character.global_position.direction_to(next_pos)
	
	character.velocity = direction.normalized() * move_speed
	
	character.check_for_door_in_path()
	
	if character.global_position.distance_to(Global.player.global_position) < 3.0:
		character.suspicion = 0.0
		transitioned.emit(self, 'Wander')
