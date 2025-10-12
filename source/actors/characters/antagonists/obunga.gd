extends Character

signal opened_door

const SPEED = 3.5
const JUMP_VELOCITY = 4.5
const MAX_DOOR_DISTANCE_ALONG_PATH := 3.0
const EYE_POSITION := Vector3.UP
const SPIT_ATTACK_COOLDOWN_TIME := 3.0

@export var shape_cast_shape: Shape3D
@export var shape_cast_transform: Transform3D

@export var test_walk: AudioStreamRandomizer
@export var test_water_walk: AudioStreamRandomizer

var do_move = false
var scripted_event: bool = false
var look_at_player: bool = false
var draggable_being_dragged: Draggable

var door_nearby := false

var suspicion := 0.0 : 
	set(value): 
		suspicion = clamp(value, 0.0, 1.0)
	get:
		return clamp(suspicion, 0.0, 1.0)

var awareness := 0.0 :
	set(value): 
		awareness = clamp(value, 0.0, 1.0)
	get:
		return clamp(awareness, 0.0, 1.0)

var look_at_pos: Vector3 = Vector3(0.0, 0.0, 1.0)

var current_state: NPCState

@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var sound_player = $SoundPlayer
@onready var footstep_player = $FootstepPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var door_area: Area3D = $DoorArea
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skeleton: Skeleton3D = $armature/Skeleton3D
@onready var spit_attack: Node3D = $armature/Skeleton3D/SpitAttack


func _ready():
	add_child(footstep_timer)
	footstep_timer.wait_time = footstep_walk_interval
	footstep_timer.one_shot = true
	_load_footsteps()
	footstep_crouch_vol += 10
	footstep_walk_vol += 10
	footstep_sprint_vol += 10
	
	state_machine.state_updated.connect(_on_state_updated)


func _process(delta):
	if Input.is_action_just_pressed("enemy_pathfind"):
		do_move = not do_move
		if not do_move:
			state_change_requested.emit("Idle")
		else:
			state_change_requested.emit("Wander")
	#if look_at_player:
	#	var bone_transform: Transform3D = skeleton.get_bone_global_pose_no_override(5)
	#	bone_transform = bone_transform.looking_at(skeleton.to_local(Global.player.cam.global_position), Vector3.UP, true)
	#	skeleton.set_bone_global_pose_override(5, bone_transform, 1.0, true)
	
	if Input.is_action_just_pressed("debug2"):
		state_change_requested.emit("Investigate", {InvestigateState.PARAM_INVESTIGATE_POSITION: Global.player.global_position})
	
	if Input.is_action_just_pressed("debug3"):
		if is_equal_approx(Engine.time_scale, 1.0):
			Engine.time_scale = 0.25
		else:
			Engine.time_scale = 1.0
	
	if current_state is SpitAttackState:
		var head_global_position: Vector3 = skeleton.to_global(skeleton.get_bone_global_pose(skeleton.find_bone('head')).origin)
		spit_attack.set_particles_and_sound_global_position(head_global_position)
	
	# TODO: Fix cheesing by running around the enemy while super close
	if current_state is SpitAttackState and not spit_attack.particles_emitted or \
			(current_state is ChasePauseState and \
			global_position.distance_to(Global.player.position) < current_state.nav_agent_target_desired_distance):
		var dir_to_player: Vector3 = (to_local(Global.player.global_position) * Vector3(1.0, 0.0, 1.0)).normalized()
		var target_angle = Vector3.FORWARD.signed_angle_to(dir_to_player, Vector3.UP)
		var diff = fposmod(target_angle + PI, TAU) - PI
		var max_turn = TAU * delta # TODO: Modify this if getting hit too often
		rotation.y += clamp(diff, -max_turn, max_turn)
	
	elif not is_zero_approx(velocity.length()):
		var direction: Vector3 = (velocity * Vector3(1.0, 0.0, 1.0)).normalized()
		if direction.length() > 0.01:
			var target_angle = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP)
			var diff = fposmod(target_angle - rotation.y + PI, TAU) - PI
			var min_turn_speed = PI / 8.0
			var max_turn_speed = 2.0 * TAU
			var proportion = clamp(abs(diff) / PI, 0.0, 1.0)
			var max_turn = lerp(min_turn_speed, max_turn_speed, proportion) * delta
			rotation.y += clamp(diff, -max_turn, max_turn)


func _physics_process(delta):
	if draggable_being_dragged:
		if draggable_being_dragged.draggable_body.rotation_degrees.y < 80:
			blend_to_new_anim("Idle")
			
			var z_dist_sign: int = sign(draggable_being_dragged.get_character_z_dist(self))
			var amount := 0.05 if current_state.name != 'Chase' else 0.2
			draggable_being_dragged.add_torque_to_draggable_body(Vector2(amount * z_dist_sign, 0.0))
		else:
			if current_state is WanderState or current_state is InvestigateState or current_state is ChasePauseState:
				blend_to_new_anim("Walk")
			elif current_state is ChaseState:
				blend_to_new_anim("Run")
			draggable_being_dragged.set_being_dragged(null)
			draggable_being_dragged = null
			opened_door.emit()
			
			
	if do_move and not draggable_being_dragged:
		#look_at_pos = lerp(look_at_pos, Vector3(velocity.x, $Armature.position.y, velocity.z).rotated(Vector3.UP, PI), 0.04)
		#$Armature.look_at(to_global(look_at_pos), Vector3.UP, false)
		
		move_and_slide()
		
		velocity.y -= gravity * delta
			
		if abs(velocity.x) > 0 or abs(velocity.z) > 0:
			if footstep_timer.time_left > footstep_walk_interval:
				footstep_timer.start(footstep_walk_interval)
			moving = true
		else:
			moving = false
			
		if water_check.is_colliding():
			in_water = true
		else:
			in_water = false


func is_near_door():
	return door_area.has_overlapping_bodies()


func check_for_door_in_path():
	var found_door: Door = null
	var path_points = nav_agent.get_current_navigation_path()
	var nav_path_index: int = nav_agent.get_current_navigation_path_index()
	
	if path_points.size() < 2 or nav_path_index >= path_points.size():
		return null
	
	var total_distance := 0.0
	path_points.insert(nav_path_index, global_position)
	for i in range(nav_path_index, path_points.size() - 1):
		var from: Vector3 = path_points[i] + EYE_POSITION
		var to: Vector3 = path_points[i + 1] + EYE_POSITION
		var segment_length: float = from.distance_to(to)
		
		var overshoot_amount: float = total_distance + segment_length - MAX_DOOR_DISTANCE_ALONG_PATH
		
		if overshoot_amount > 0:
			to = from + from.direction_to(to) * (segment_length - overshoot_amount)
		
		var collision = check_path_segment(from, to)
		
		if collision:
			found_door = collision.collider.get_parent()
			break
		elif overshoot_amount > 0:
			break
			
		total_distance += segment_length
	
	if found_door:
		if found_door.being_dragged_by != self:
			found_door.set_being_dragged(self)
			draggable_being_dragged = found_door


func check_path_segment(from: Vector3, to: Vector3) -> Dictionary:
	var door_collision_layer: int = 8 + 16
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	
	var direction: Vector3 = (to - from).normalized()
	var new_basis := Basis.looking_at(direction, Vector3.UP) if direction != Vector3.ZERO else Basis()
	
	query.shape = shape_cast_shape
	query.transform = Transform3D(new_basis, from)
	query.motion = to - from
	query.collision_mask = door_collision_layer
	
	var results: Array[Dictionary] = space_state.intersect_shape(query)
	
	if results.size() > 0:
		return results[0]
	else:
		return {}


func player_in_fov(fov_angle: float = 110.0):
	var direction_to_player: Vector3 = (global_position.direction_to(Global.player.global_position) * Vector3(1.0, 0.0, 1.0)).normalized()
	var forward: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	return forward.dot(direction_to_player) > cos(deg_to_rad(fov_angle))


func can_see_player(max_distance: float = 0.0, fov_angle: float = 110.0) -> bool:
	if not is_equal_approx(max_distance, 0.0) and max_distance < global_position.distance_to(Global.player.global_position):
		return false
		
	if not player_in_fov(fov_angle):
		return false
	
	return ray_to_player_valid()


func ray_to_player_valid() -> bool:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.new()
	
	query.from = global_position + Vector3.UP
	query.to = Global.player.global_position - Vector3.UP * 0.5 # TOOD: Deal with player scene origin in middle
	query.collision_mask = 1 + 2 + 8
	
	var collision = space.intersect_ray(query)
		
	return collision and collision.collider == Global.player


func is_max_suspicion() -> bool:
	return is_equal_approx(suspicion, 1.0)


func is_min_suspicion() -> bool:
	return is_equal_approx(suspicion, 0.0)


func is_max_awareness() -> bool:
	return is_equal_approx(awareness, 1.0)


func is_min_awareness() -> bool:
	return is_equal_approx(awareness, 0.0)


func play_footstep():
	if not in_water:
		footstep_player.stream = test_walk
		footstep_player.play()
	else:
		if footstep_player.stream != test_water_walk:
			footstep_player.stream = test_water_walk
		footstep_player.play()


func play_sound_one_shot(sound: AudioStream):
	sound_player.stream = sound
	sound_player.play()


func blend_to_new_anim(anim_name: String, duration := 0.5):
	var point := Vector2.ZERO
	match anim_name:
		"Walk":
			point = Vector2(1.0, 0.0)
		"Run":
			point = Vector2(0.0, 1.0)
		"Idle":
			point = Vector2(0.0, 0.0)
		
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(animation_tree, "parameters/locomotion/blend_position", point, duration)
	if anim_name == "SpitAttack":
		animation_tree.set("parameters/TimeSeek/seek_request", 0.0)


func _on_state_updated(new_state: NPCState):
	current_state = new_state
	nav_agent.target_desired_distance = new_state.nav_agent_target_desired_distance


func walk_in_servants_quarters_event(end_position: Vector3):
	rotation.y = 0.0
	#spear.visible = false
	scripted_event = true
	do_move = true
	var tween: Tween = get_tree().create_tween()
	#tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 1.0, 0.5).from(0.0)
	nav_agent.set_target_position(end_position)
	await nav_agent.target_reached
	#anim_tree.set("parameters/locomotion/blend_position", Vector2(0.0, 1.0))
	do_move = false
	scripted_event = false


func first_encounter_event(end_position: Vector3):
	rotation.y = 0.0
	$Armature.rotation.y = PI
	scripted_event = true
	do_move = true
	var tween: Tween = get_tree().create_tween()
	#tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 1.0, 0.5).from(0.0)
	nav_agent.set_target_position(end_position)
	await nav_agent.target_reached
	#anim_tree.set("parameters/locomotion/blend_position", Vector2(0.0, 0.0))
	do_move = false
	scripted_event = false
	global_position = Vector3(0.0, 200.0, 0.0)


func kitchen_encounter_event():
	rotation.y = 0.0
	scripted_event = true
	do_move = true
	look_at_player = true
	var tween: Tween = get_tree().create_tween()
	#tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 1.0, 0.5).from(0.0)
	tween.parallel().tween_property(footstep_player, "volume_db", 0, 2.0).from(-15)
	nav_agent.set_target_position(Global.player.global_position)
	#play_sound_one_shot(load("res://source/assets/sounds/monster/monster_sound_2.ogg"))
	await nav_agent.target_reached
	Global.player.torch.burning_player.playing = false
	Global.world.remove_child(Global.player)
	do_move = false
	scripted_event = false
	


func crouch():
	crouching = true
	var tween: Tween = get_tree().create_tween()
	#tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(0.0, -1.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 0.5, 0.25)


func uncrouch():
	crouching = false
	var tween: Tween = get_tree().create_tween()
	#tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 1.0, 0.25)
