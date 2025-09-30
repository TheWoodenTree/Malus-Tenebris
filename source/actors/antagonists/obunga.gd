extends Character

signal opened_door

enum State {IDLE, WANDER, PATROL, CHASE, ATTACK, SCRIPTED_EVENT}

const SPEED = 3.5
const JUMP_VELOCITY = 4.5
const MAX_DOOR_DISTANCE_ALONG_PATH := 3.0

@export var shape_cast_shape: Shape3D
@export var shape_cast_transform: Transform3D

var do_move = false
var scripted_event: bool = false
var look_at_player: bool = false
var draggable_being_dragged: Draggable

var look_at_pos: Vector3 = Vector3(0.0, 0.0, 1.0)

@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var player_seek_ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
@onready var skeleton = $Armature/Skeleton3D
@onready var animation_player = $AnimPlayer
@onready var anim_tree = $AnimTree
@onready var sound_player = $SoundPlayer
@onready var footstep_player = $FootstepPlayer
@onready var spear = $Spear


func _ready():
	add_child(footstep_timer)
	footstep_timer.wait_time = footstep_walk_interval
	footstep_timer.one_shot = true
	_load_footsteps()
	footstep_crouch_vol += 10
	footstep_walk_vol += 10
	footstep_sprint_vol += 10
	player_seek_ray.collision_mask = 3


func _process(_delta):
	if Input.is_action_just_pressed("enemy_pathfind"):
		do_move = !do_move
		anim_tree.set("parameters/locomotion/blend_position", Vector2(1.0, 0.0))
		rotation.y = 0.0
	if look_at_player:
		var bone_transform: Transform3D = skeleton.get_bone_global_pose_no_override(5)
		bone_transform = bone_transform.looking_at(skeleton.to_local(Global.player.cam.global_position), Vector3.UP, true)
		skeleton.set_bone_global_pose_override(5, bone_transform, 1.0, true)
	
	if do_move:
		pass


func _physics_process(delta):
	if draggable_being_dragged:
		if draggable_being_dragged.draggable_body.rotation_degrees.y < 80:
			var z_dist_sign: int = sign(draggable_being_dragged.get_character_z_dist(self))
			draggable_being_dragged.add_torque_to_draggable_body(Vector2(0.05 * z_dist_sign, 0.0))
		else:
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
	elif draggable_being_dragged:
		anim_tree.set("parameters/locomotion/blend_position", Vector2(0.0, 1.0))


func check_for_door_in_path():
	var found_door: Door = null
	var path_points = nav_agent.get_current_navigation_path()
	var nav_path_index: int = nav_agent.get_current_navigation_path_index()
	
	if path_points.size() < 2 or nav_path_index >= path_points.size():
		return null
	
	var total_distance := 0.0
	path_points.insert(nav_path_index, global_position)
	for i in range(nav_path_index, path_points.size() - 1):
		var from: Vector3 = path_points[i] + Vector3.UP
		var to: Vector3 = path_points[i + 1] + Vector3.UP
		var segment_length: float = from.distance_to(to)
		
		var overshoot_amount: float = total_distance + segment_length - MAX_DOOR_DISTANCE_ALONG_PATH
		
		if overshoot_amount > 0:
			to = from + from.direction_to(to) * (segment_length - overshoot_amount)
		
		var collision = check_path_segment(from, to)
		
		if collision:
			print('cunt')
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
	var door_collision_layer: int = 8
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
		


func seek_player():
	var space = get_world_3d().direct_space_state
	player_seek_ray.from = self.global_position
	player_seek_ray.to = Global.player.global_position
	var collision: Dictionary
	collision = space.intersect_ray(player_seek_ray)
	if collision.get("collider") == Global.player and $ScreetchCooldown.time_left == 0:
		#$ScreetchPlayer.play()
		$ScreetchCooldown.start()


func play_sound_one_shot(sound: AudioStream):
	sound_player.stream = sound
	sound_player.play()


func walk_in_servants_quarters_event(end_position: Vector3):
	rotation.y = 0.0
	spear.visible = false
	scripted_event = true
	do_move = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 1.0, 0.5).from(0.0)
	nav_agent.set_target_position(end_position)
	await nav_agent.target_reached
	anim_tree.set("parameters/locomotion/blend_position", Vector2(0.0, 1.0))
	do_move = false
	scripted_event = false


func first_encounter_event(end_position: Vector3):
	rotation.y = 0.0
	$Armature.rotation.y = PI
	scripted_event = true
	do_move = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 1.0, 0.5).from(0.0)
	nav_agent.set_target_position(end_position)
	await nav_agent.target_reached
	anim_tree.set("parameters/locomotion/blend_position", Vector2(0.0, 0.0))
	do_move = false
	scripted_event = false
	global_position = Vector3(0.0, 200.0, 0.0)


func kitchen_encounter_event():
	rotation.y = 0.0
	scripted_event = true
	do_move = true
	look_at_player = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
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
	tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(0.0, -1.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 0.5, 0.25)


func uncrouch():
	crouching = false
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(anim_tree, "parameters/locomotion/blend_position", Vector2(1.0, 0.0), 0.5)
	tween.parallel().tween_property(self, "speed_multiplier", 1.0, 0.25)
