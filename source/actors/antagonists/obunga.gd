extends Character


const SPEED = 3.5
const JUMP_VELOCITY = 4.5

var do_move = false

var look_at_pos: Vector3

@onready var nav_agent: NavigationAgent3D = $nav_agent
@onready var player_seek_ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
@onready var skeleton = $armature/Skeleton3D
@onready var animation_player = $AnimationPlayer
@onready var footstep_player = $armature/Skeleton3D/footstep_player


func _ready():
	add_child(footstep_timer)
	footstep_timer.wait_time = footstep_walk_interval
	footstep_timer.one_shot = true
	_load_footsteps()
	footstep_crouch_vol += 10
	footstep_walk_vol += 10
	footstep_sprint_vol += 10
	player_seek_ray.collision_mask = 3
	animation_player.play("Armature_001|mixamo_com|Layer0 Retarget_004")


func _process(_delta):
	if Input.is_action_just_pressed("enemy_pathfind"):
		do_move = !do_move
		#$Sprite3D.visible = true
	#rotation.y = Global.player.cam.rotation.y
	var bone_transform: Transform3D = skeleton.get_bone_global_pose_no_override(5)
	bone_transform = bone_transform.looking_at(skeleton.to_local(Global.player.cam.global_position), Vector3.UP, true)
	skeleton.set_bone_global_pose_override(5, bone_transform, 1.0, true)
	
	look_at_pos = lerp(look_at_pos, Vector3(velocity.x, $armature.position.y, velocity.z), 0.01)
	$armature.look_at(to_global(look_at_pos), Vector3.UP, true)


func _physics_process(delta):
	if do_move:
		seek_player()
		
		var new_velocity: Vector3
		var curr_pos = global_transform.origin
		var next_pos = nav_agent.get_next_path_position()
		#Global.world.get_node("test").global_position = next_pos
		new_velocity = (next_pos - curr_pos).normalized() * SPEED
		velocity = new_velocity
		
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
		
			
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		#if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_left") or \
		#Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			
		#if direction:
		#	velocity.x = direction.x * SPEED
		#	velocity.z = direction.z * SPEED
		#else:
		#	velocity.x = move_toward(velocity.x, 0, SPEED)
		#	velocity.z = move_toward(velocity.z, 0, SPEED)
		
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
		#if footstep_timer.time_left == 0 and moving:
		#	_play_footstep_sound()
		
		if nav_agent.is_target_reached():
			do_move = false
			#Global.player.do_caught_sequence(global_position)


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
	nav_agent.set_target_position(Global.player.global_position)
