extends Character

const NOCLIP_SPEED: float = 20.0
const MAX_DIST_FROM_DRAGGABLE: float = 5.0
const MAX_AFFLICTION_TIMER_ALLOW_DRINK: float = 700.0

var torch_range = 10.0
var torch_energy = 0.75
var time_when_started_moving = 0.0

var facing_dir: Vector3
var input_dir = Vector3.ZERO
var global_input_dir = Vector3.ZERO
var global_input_dir_last_frame = Vector3.ZERO
var max_speed = walk_speed

var draggable_touch_position := Vector3.ZERO
var draggable_angle_on_touch: float

var torch: Object
var looking_at: Interactable
var looking_at_last_frame: Interactable
var last_looked_at: Object = null
var held_item_data: ItemData = null
var held_item: MeshInstance3D = null
var draggable_being_dragged: Object = null # Set by door script

var has_torch: bool = false
var in_menu: bool = false
var crouching_last_frame: bool = false
var first_item_picked_up: bool = false
var first_item_held: bool = false
var first_door_unlocked: bool = false
var noclip_on: bool = false
var picked_up_larder_key: bool = false
var scripted_event: bool = false
var in_world: bool = false

var gulp_sound: AudioStream = preload("res://source/assets/sounds/liquid/gulp.ogg")
var sigh_of_relief_sound: AudioStream = preload("res://source/assets/sounds/player_character/sigh_of_relief.ogg")
var thrown_item: Resource = preload("res://source/actors/misc/thrown_bottle.tscn")

@onready var head = $head_controller
@onready var bob_controller = $head_controller/bob_controller
@onready var cam = $head_controller/bob_controller/camera
@onready var torch_cam = $head_controller/bob_controller/camera/viewport_cont/torch_cam_viewport/torch_cam
@onready var interact_ray = $head_controller/bob_controller/camera/interact_raycast
@onready var torch_pos = $head_controller/bob_controller/camera/torch_pos
@onready var light = $head_controller/base_light
@onready var held_item_marker = $head_controller/bob_controller/camera/held_item_marker
@onready var noise_player = $noise_player
@onready var rucksack_player = $rucksack_player
@onready var fear_player = $fear_player
@onready var fear_pulse_player = $fear_pulse_player
@onready var affliction_timer = $affliction_timer

@export var debug_has_torch: bool = false
@export var debug_no_tutorials: bool = false
@export var is_omnipotent_door_god: bool = false

signal crouched
signal looked_at_interactable(interactable_type: Interactable.Type)
signal looked_away_from_interactable
signal holding_self_useable(interactable_type: Interactable.Type)
signal draggable_interacted


func _ready() -> void:
	Global.ui.inventory_opened.connect(stop_holding_item.bind(false))
	
	if debug_has_torch:
		debug_get_torch()
	
	light.omni_range = 3.0
	light.default_range = 3.0
	
	footstep_timer.wait_time = footstep_walk_interval
	footstep_timer.one_shot = true
	add_child(footstep_timer)
	_load_footsteps()
	
	in_world = true


func _process(_delta: float) -> void:
	_handle_input()
	
	torch_cam.global_transform = cam.global_transform
	if held_item:
		held_item.global_position = lerp(held_item.global_position, held_item_marker.global_position, 0.025)
		var rot_offset_x: float = deg_to_rad(held_item_data.hold_rotation_offset.x)
		var rot_offset_y: float = deg_to_rad(held_item_data.hold_rotation_offset.y)
		var rot_offset_z: float = deg_to_rad(held_item_data.hold_rotation_offset.z)
		held_item.rotation = cam.rotation + Vector3(rot_offset_x, rot_offset_y, rot_offset_z)
		held_item.scale = Vector3.ONE * held_item_data.hold_scale_multiplier
	global_input_dir = _get_input_dir()
	
	if global_input_dir != Vector3.ZERO and global_input_dir_last_frame == Vector3.ZERO:
		time_when_started_moving = Time.get_ticks_msec()
		bob_controller.bob_timer.seek(0.0)
		bob_controller.bob_timer.play("timer")
	
	if not in_menu:
		var collider = interact_ray.get_collider()
		_handle_look_at(collider)
	
	# Stop dragging if too far from draggable
	if is_instance_valid(draggable_being_dragged):
		# Comically long line of code:
		#var dist_from_touch_point: float = cam.global_position.distance_to(draggable_being_dragged.draggable_body.to_global(draggable_being_dragged.draggable_body.to_local(draggable_touch_position).rotated(draggable_being_dragged.rotation_axis, draggable_being_dragged.get_draggable_body_angle() - draggable_angle_on_touch)))
		var local_touch_point: Vector3 = draggable_being_dragged.draggable_body.to_local(draggable_touch_position)
		var angle_diff: float = draggable_being_dragged.get_draggable_body_angle() - draggable_angle_on_touch
		var rotated_touch_point: Vector3 = local_touch_point.rotated(draggable_being_dragged.rotation_axis, angle_diff)
		var global_rotated_touch_point: Vector3 = draggable_being_dragged.draggable_body.to_global(rotated_touch_point)
		var dist_from_touch_point: float = cam.global_position.distance_to(global_rotated_touch_point)
		if dist_from_touch_point > MAX_DIST_FROM_DRAGGABLE:
			draggable_being_dragged.set_player_dragging(false)
			draggable_being_dragged = null


func _physics_process(delta: float) -> void:
	if not in_menu and not scripted_event:
		_handle_physics_input()
		facing_dir = get_facing_dir()
		_move(delta)
		moving_last_frame = moving
		global_input_dir_last_frame = global_input_dir


#TODO: Fix camera bobbing for sprint affecting crouch camera bobbing
func _handle_input():
	if Input.is_action_just_pressed("cancel") and held_item_data and not Global.ui.block_inventory_open:
		stop_holding_item(true)
	
	if Input.is_action_just_pressed("noclip"):
		noclip_on = !noclip_on
		set_collision_layer_value(2, !noclip_on)
		set_collision_mask_value(1, !noclip_on)
	
	var can_self_use: bool = held_item_data and held_item_data.self_useable and not looking_at and not draggable_being_dragged
	if Input.is_action_just_pressed("interact") and can_self_use and not in_menu:
		if held_item_data.self_useable_script:
			held_item.use()
		else:
			push_error("Self-useable has no attached script")
	
	if Input.is_action_just_released("interact"):
		if is_instance_valid(draggable_being_dragged):
			draggable_being_dragged.set_player_dragging(false)
			draggable_being_dragged = null
	
	#if Input.is_action_just_pressed("throw") and is_holding_item("Ruboleum Vial"):
	#	var instance: RigidBody3D = thrown_item.instantiate()
	#	#instance.get_node("mesh").mesh = held_item
	#	Global.world.add_child(instance)
	#	instance.global_transform = held_item.global_transform
	#	delete_held_item()
	#	await get_tree().physics_frame # Two awaits needed for impulse to be correctly applied
	#	await get_tree().physics_frame # since it is being applied the frame the instance is added to tree
	#	instance.apply_impulse(facing_dir * 15.0 + velocity, Vector3(0.0, 0.185, 0.0))


func _handle_physics_input():
	if not crouching:
		if Input.is_action_pressed("sprint"):
			sprinting = true
			max_speed = sprint_speed
			footstep_timer.wait_time = footstep_sprint_interval / speed_multiplier
			
			if footstep_timer.time_left > footstep_sprint_interval / speed_multiplier:
				footstep_timer.start(footstep_sprint_interval)
		else:
			sprinting = false
			max_speed = walk_speed
			
			footstep_timer.wait_time = footstep_walk_interval / speed_multiplier
			if footstep_timer.time_left > footstep_walk_interval / speed_multiplier:
				footstep_timer.start(footstep_walk_interval)
	
	# Turbo scuffed crouching logic (refactor in favor of state machine please)
	if not Input.is_action_pressed("crouch") and not crouch_trans:
		if crouching and _can_stand():
			var crouch_tween = create_tween()
			max_speed = walk_speed
			footstep_timer.wait_time = footstep_walk_interval / speed_multiplier
			
			crouch_tween.tween_property(head, "position:y", -crouch_dist, \
				crouch_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).as_relative()
			
			crouching = false
			crouch_trans = true
			get_tree().call_group("player_detection_areas", "set_process_mode", Node.PROCESS_MODE_DISABLED)
			standing_collision.disabled = false
			crouching_collision.disabled = true
			get_tree().call_group("player_detection_areas", "set_process_mode", Node.PROCESS_MODE_INHERIT)
			crouch_tween.tween_callback(Callable(self, "set").bind("crouch_trans", false))
	
	elif Input.is_action_pressed("crouch") and not crouch_trans:
		if not crouching:
			var crouch_tween = create_tween()
			max_speed = crouch_speed
			footstep_timer.wait_time = footstep_crouch_interval / speed_multiplier
			
			crouch_tween.tween_property(head, "position:y", crouch_dist, \
				crouch_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).as_relative()
			
			crouching = true
			crouch_trans = true
			get_tree().call_group("player_detection_areas", "set_process_mode", Node.PROCESS_MODE_DISABLED)
			crouching_collision.disabled = false
			standing_collision.disabled = true
			get_tree().call_group("player_detection_areas", "set_process_mode", Node.PROCESS_MODE_INHERIT)
			crouch_tween.tween_callback(Callable(self,"set").bind("crouch_trans", false))
			crouched.emit()
	
	if Input.is_action_just_pressed("throw") and has_torch:
		print("this will break the game no cap what are you doing")
		#throw_torch()
	
	crouching_last_frame = crouching


func inventory_add_item(item_data: ItemData):
	Global.ui.inventory_menu.add_item(item_data)
	if not first_item_picked_up:
		first_item_picked_up = true


func inventory_remove_item(item_data: ItemData):
	Global.ui.inventory_menu.remove_item(item_data)


func hold_item(item_data: ItemData):
	held_item_data = item_data
	held_item = item_data.mesh
	add_child(held_item)
	held_item.position = Vector3.ZERO
	held_item.scale *= item_data.hold_scale_multiplier
	if held_item_data.self_useable:
		held_item.material_overlay.set_shader_parameter("outlineOn", true)
		holding_self_useable.emit(Interactable.Type.NOTE)
	else:
		held_item.material_overlay.set_shader_parameter("outlineOn", false)
		
	if not first_item_held and is_holding_key() and not debug_no_tutorials:
		Global.ui.hint_popup("Interact with the door while holding the key", 5.0)
		first_item_held = true


func delete_held_item():
	remove_child(held_item)
	inventory_remove_item(held_item_data)
	held_item_data = null
	held_item = null


func stop_holding_item(play_sound: bool):
	if held_item:
		remove_child(held_item)
	held_item_data = null
	held_item = null
	if play_sound:
		rucksack_player.play()


func set_held_item_visibility(new_visibility: bool):
	held_item.visible = new_visibility


func set_held_item_global_transform(new_transform: Transform3D):
	held_item.global_transform = new_transform


func set_draggable_being_dragged(draggable: Object):
	draggable_being_dragged = draggable
	if draggable_being_dragged:
		draggable_interacted.emit(draggable_being_dragged)
		draggable_touch_position = interact_ray.get_collision_point()
		draggable_angle_on_touch = draggable.get_draggable_body_angle()
		Global.ui.toggle_draggable_progress_bar(true)
	else:
		draggable_touch_position = Vector3.ZERO
		Global.ui.toggle_draggable_progress_bar(false)


func play_sound_one_shot(sound: AudioStream):
	noise_player.stream = sound
	noise_player.play()


func is_holding_item(item_name: String):
	return held_item_data and held_item_data.name == item_name


func is_holding_key():
	return held_item_data and held_item_data.name.contains("Key")


# Check if the standing collision shape collides with the world
func _can_stand():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.set_shape(standing_collision.shape)
	query.transform = standing_collision.global_transform
	query.collision_mask = collision_mask
	var results = space_state.get_rest_info(query)
	
	return results.is_empty()


func _handle_look_at(collider):
	# Don't collide with Area3Ds that are in the world layer because those are for
	# adjusting reverb based on room because for some reason they have to have collision layer
	# bit 0 set to enabled to work
	if collider != null and collider is Area3D and collider.get_collision_layer_value(1) and collider.name != "collision_blocker":
		interact_ray.add_exception(collider)
	# Only handle "look ats" if collider is non-null and is not the world
	# Note that collisions with the world are still desired as interacting with
	# something through a wall is not intended
	if collider != null and collider.get_collision_layer_value(1) == false:
		looking_at = collider.interactable_ancestor
		last_looked_at = looking_at
		looking_at.being_looked_at = true
		if looking_at.interactable:
			looked_at_interactable.emit(looking_at.get_interactable_type())
			if held_item:
				held_item.material_overlay.set_shader_parameter("outlineOn", false)
		if Input.is_action_just_pressed("interact"):
			looking_at.interact()
	else:
		looking_at = null
		if held_item and held_item_data.self_useable and not draggable_being_dragged:
			held_item.material_overlay.set_shader_parameter("outlineOn", true)
	
	var hide_interact_icon: bool = not looking_at or looking_at and not looking_at.interactable
	if not draggable_being_dragged and hide_interact_icon and Global.ui.interact_icon.visible:
		var is_holding_self_useable: bool = held_item_data and held_item_data.self_useable
		looked_away_from_interactable.emit(is_holding_self_useable)
	
	# Let the last interactable looked at know (if it isn't null or hasn't been freed) 
	# it's not being looked at anymore
	if looking_at != looking_at_last_frame and is_instance_valid(looking_at_last_frame):
		looking_at_last_frame.being_looked_at = false
	
	looking_at_last_frame = looking_at


func get_facing_dir():
	var vec = Vector3(1, 0, 0).rotated(Vector3.UP, cam.rotation.y)
	var xz_dir = Vector3(0, 0, -1).rotated(Vector3.UP, cam.rotation.y)
	var dir = xz_dir.rotated(vec, cam.rotation.x)
	return dir


func get_forward_dir():
	return Vector3(0, 0, -1).rotated(Vector3.UP, cam.rotation.y)


func get_interact_raycast_collision_normal():
	return interact_ray.get_collision_normal()


func _move(delta):
	move_and_slide()
	
	# Rotate input direction to match head facing direction
	input_dir = global_input_dir.rotated(Vector3.UP, cam.rotation.y)
	
	if not noclip_on:
		velocity.x = lerp(velocity.x, input_dir.x * max_speed * speed_multiplier, accel)
		velocity.z = lerp(velocity.z, input_dir.z * max_speed * speed_multiplier, accel)
	else:
		velocity = facing_dir * NOCLIP_SPEED * input_dir.length()
	
	if not noclip_on:
		velocity.y -= gravity * delta
	
	for i in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider is RigidBody3D:
			collider.apply_force(collision.get_normal() * -50.0)
	
	if abs(input_dir.x) > 0 or abs(input_dir.z) > 0:
		moving = true
	else:
		moving = false
	
	if water_check.is_colliding():
		in_water = true
	else:
		in_water = false
	if footstep_timer.time_left == 0 and moving:
		_play_footstep_sound()


func _get_input_dir():
	var dir = Vector3.ZERO
	dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dir.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	
	return dir.normalized()


func play_pickup_sound(pickup_sound_player: AudioStreamPlayer3D):
	pickup_sound_player.play()
	await get_tree().create_timer(0.05, false).timeout
	rucksack_player.play()
	# Pickup is freed when this function returns, wait for its sound effect to
	# finish playing
	await pickup_sound_player.finished


func cam_look_at_over_time(pos: Vector3, time: float):
	# Scuffed
	var initial_rot = cam.rotation
	cam.look_at(pos)
	var after_rot = cam.rotation
	cam.rotation = initial_rot
	
	var to_rot = after_rot - initial_rot
	if abs(after_rot.x - initial_rot.x) < abs(after_rot.x - (initial_rot.x - TAU)):
		to_rot.x = after_rot.x - initial_rot.x
	else:
		to_rot.x = after_rot.x - (initial_rot.x - TAU)

	if abs(after_rot.y - initial_rot.y) < abs(after_rot.y - (initial_rot.y - TAU)):
		to_rot.y = after_rot.y - initial_rot.y
	else:
		to_rot.y = after_rot.y - (initial_rot.y - TAU)
	
	var _anim_dur_scale = (abs(to_rot.x) + abs(to_rot.y)) / TAU
	
	if abs(to_rot.x) > PI / 6 or abs(to_rot.y) > PI / 3:
		var cam_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
		cam_tween.tween_property(cam, "rotation", to_rot, time).as_relative()
	
	#await get_tree().create_timer(0.35 * anim_dur_scale + 0.25).timeout
	#Global.ui.display_menu(Global.ui.death_screen_res)


func debug_get_torch():
	Global.torch.interact()
	Global.player.torch.light_torch()


func _on_allow_interactable_sheen_area_area_entered(area):
	if area.interactable_ancestor.enable_highlight_sheen:
		area.interactable_ancestor.enable_sheen()


func _on_allow_interactable_sheen_area_area_exited(area):
	if area.interactable_ancestor.enable_highlight_sheen:
		area.interactable_ancestor.disable_sheen()


# Only play fire burning audio from nearby fire sources since there's a lot of them
func _on_fire_burning_sound_area_area_entered(area):
	if area.interactable_ancestor.lit:
		var start_time: float = Global.torch.burning_player.get_playback_position() + 30.0
		start_time = wrapf(start_time, 0.0, Global.torch.burning_player.stream.get_length())
		area.interactable_ancestor.fire.burning_player.play(start_time)
		# Only render nearby lights on the second layer for performance
		# Second layer is for held items so they don't clip into walls
		#area.interactable_ancestor.fire.light.set_layer_mask_value(2, true)


func _on_fire_burning_sound_area_area_exited(area):
	area.interactable_ancestor.fire.burning_player.stop()
	area.interactable_ancestor.fire.light.set_layer_mask_value(2, false)
