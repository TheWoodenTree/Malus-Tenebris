class_name WanderState
extends State

@export var move_speed := 3.5
@export var max_wander_time := 20.0
@export var min_wander_time := 5.0

var wander_to_position: float
var wander_time: float

@onready var wander_timer := Timer.new()


func _ready() -> void:
	add_child(wander_timer)
	wander_timer.one_shot = true
	wander_timer.timeout.connect(randomize_wander)


func _on_set_character(_character: CharacterBody3D):
	nav_agent.velocity_computed.connect(func(velocity): character.velocity = velocity)


func enter() -> void:
	randomize_wander()


func exit() -> void:
	pass


func physics_update(_delta: float):
	var new_velocity: Vector3
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = character.global_position.direction_to(next_pos)
	
	new_velocity = direction.normalized() * move_speed
	character.velocity = new_velocity
	
	nav_agent.set_velocity(new_velocity)
	
	character.check_for_door_in_path()
	
	if nav_agent.is_target_reached():
		randomize_wander()


func randomize_wander():
	for i in range(100):
		var navigation_map: RID = nav_agent.get_navigation_map()
		var random_point = NavigationServer3D.map_get_random_point(navigation_map, 1, true)
		
		nav_agent.set_target_position(random_point)
		
		if nav_agent.is_target_reachable():
			wander_time = randf_range(min_wander_time, max_wander_time)
			wander_timer.wait_time = wander_time
			wander_timer.start()
			return
			
	push_error(character.name + ' tried to wander to unreachable points too many times')
