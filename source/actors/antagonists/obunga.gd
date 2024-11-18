extends Character


const SPEED = 3.5
const JUMP_VELOCITY = 4.5

var do_move = false
var scripted_event: bool = false
var look_at_player: bool = false

var look_at_pos: Vector3 = Vector3(0.0, 0.0, 1.0)

@onready var nav_agent: NavigationAgent3D = $nav_agent
@onready var player_seek_ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
@onready var skeleton = $armature/Skeleton3D
@onready var animation_player = $anim_player
@onready var anim_tree = $anim_tree
@onready var sound_player = $sound_player
@onready var footstep_player = $footstep_player
@onready var spear = $spear


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
	if do_move:
		if not scripted_event:
			seek_player()
		
		var new_velocity: Vector3
		var curr_pos = global_transform.origin
		var next_pos = nav_agent.get_next_path_position()
		new_velocity = (next_pos - curr_pos).normalized() * SPEED * speed_multiplier
		velocity = new_velocity
		
		look_at_pos = lerp(look_at_pos, Vector3(velocity.x, $armature.position.y, velocity.z).rotated(Vector3.UP, PI), 0.04)
		$armature.look_at(to_global(look_at_pos), Vector3.UP, false)
		
		move_and_slide()
		if is_on_wall():
			var wall_normal: Vector3 = get_wall_normal()
			if (abs(wall_normal.x) > 0.0 and abs(wall_normal.x) > abs(wall_normal.z)):
				if new_velocity.z > 0.0:
					new_velocity = Vector3(0.0, velocity.y, SPEED)
				else:
					new_velocity = Vector3(0.0, velocity.y, -SPEED)
			elif (abs(wall_normal.z) > 0.0 and abs(wall_normal.z) > abs(wall_normal.x)):
				if new_velocity.x > 0.0:
					new_velocity = Vector3(SPEED, velocity.y, 0.0)
				else:
					new_velocity = Vector3(-SPEED, velocity.y, 0.0)
			velocity = new_velocity
			move_and_slide()
			
		#if not is_on_floor():
		velocity.y -= gravity * delta
			
		#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#	velocity.y = JUMP_VELOCITY
			
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
			
		if nav_agent.is_target_reached():
			do_move = false


func seek_player():
	var space = get_world_3d().direct_space_state
	player_seek_ray.from = self.global_position
	player_seek_ray.to = Global.player.global_position
	var collision: Dictionary
	collision = space.intersect_ray(player_seek_ray)
	if collision.get("collider") == Global.player and $screetch_cooldown.time_left == 0:
		#$screetch_player.play()
		$screetch_cooldown.start()


func update_target_position():
	if not scripted_event:
		nav_agent.set_target_position(Global.player.global_position)


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
	$armature.rotation.y = PI
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
