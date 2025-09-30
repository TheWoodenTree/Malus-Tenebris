extends Character

const NOCLIP_SPEED: float = 20.0
const MAX_DIST_FROM_DRAGGABLE: float = 5.0

var torch_range = 10.0
var torch_energy = 0.75
var time_when_started_moving = 0.0

var facing_dir: Vector3
var input_dir = Vector3.ZERO
var global_input_dir = Vector3.ZERO
var global_input_dir_last_frame = Vector3.ZERO
var max_speed = walk_speed

var draggable_local_touch_position := Vector3.ZERO

var torch: Object
var targeted_interactable: Interactable
var held_item_data: ItemData = null
var held_item: Pickup = null
var draggable_being_dragged: Draggable = null

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

@onready var head = $HeadController
@onready var bob_controller = $HeadController/BobController
@onready var cam = $HeadController/BobController/Camera
@onready var torch_cam = $HeadController/BobController/Camera/ViewportCont/TorchCamViewport/TorchCam
@onready var interact_ray = $HeadController/BobController/Camera/InteractRaycast
@onready var torch_pos = $HeadController/BobController/Camera/TorchPos
@onready var light = $HeadController/BobController/Camera/BaseLight
@onready var held_item_marker = $HeadController/BobController/Camera/HeldItemMarker
@onready var hourglass_marker: Marker3D = $HeadController/BobController/Camera/HourglassMarker
@onready var noise_player = $NoisePlayer
@onready var rucksack_player = $RucksackPlayer
@onready var fear_player = $FearPlayer
@onready var fear_pulse_player = $FearPulsePlayer

@export var debug_has_torch: bool = false
@export var debug_no_tutorials: bool = false
@export var is_omnipotent_door_god: bool = false

signal crouched
signal interactable_targeted(interactable_type: Interactable.Type)
signal interactable_untargeted
signal holding_self_useable(interactable_type: Interactable.Type)


func _ready() -> void:
	Global.ui.inventory_opened.connect(stop_holding_item.bind(false))
	
	if debug_has_torch:
		debug_get_torch()
	
	light.spot_range = 3.0
	light.default_energy = 1.0
	
	footstep_timer.wait_time = footstep_walk_interval
	footstep_timer.one_shot = true
	add_child(footstep_timer)
	_load_footsteps()
	
	in_world = true


func _process(_delta: float) -> void:
	_handle_input()
	#light.global_rotation = cam.global_rotation
	torch_cam.global_transform = cam.global_transform
	if held_item:
		var held_item_pos: Vector3 = held_item_marker.global_position if held_item_data.name != "Hourglass" else hourglass_marker.global_position
		held_item.global_position = lerp(held_item.global_position, held_item_pos, 0.025)
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
	
	# Stop dragging if too far from draggable
	if is_instance_valid(draggable_being_dragged):
		# Comically long line of code:
		#var dist_from_touch_point: float = cam.global_position.distance_to(draggable_being_dragged.draggable_body.to_global(draggable_being_dragged.draggable_body.to_local(draggable_local_touch_position).rotated(draggable_being_dragged.rotation_axis, draggable_being_dragged.get_draggable_body_angle() - draggable_angle_on_touch)))
		#var local_touch_point: Vector3 = draggable_being_dragged.draggable_body.to_local(draggable_local_touch_position)
		#var angle_diff: float = draggable_being_dragged.get_draggable_body_angle() - draggable_angle_on_touch
		#var rotated_touch_point: Vector3 = local_touch_point.rotated(draggable_being_dragged.rotation_axis_vector, angle_diff)
		#var global_rotated_touch_point: Vector3 = draggable_being_dragged.draggable_body.to_global(rotated_touch_point)
		#var dist_from_touch_point: float = cam.global_position.distance_to(global_rotated_touch_point)
		#if dist_from_touch_point > MAX_DIST_FROM_DRAGGABLE:
			#set_draggable_being_dragged(null)
		
		var current_global_touch_position: Vector3 = draggable_being_dragged.draggable_body.to_global(draggable_local_touch_position)
		var dist_from_touch_point: float = cam.global_position.distance_to(current_global_touch_position)
		if dist_from_touch_point > MAX_DIST_FROM_DRAGGABLE:
			set_draggable_being_dragged(null)


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
		set_collision_mask_value(4, !noclip_on)
	
	var can_self_use: bool = held_item_data and held_item_data.self_useable and not targeted_interactable and not draggable_being_dragged
	if Input.is_action_just_pressed("interact") and can_self_use and not in_menu:
		if held_item_data.self_useable_script:
			held_item.use()
		else:
			push_error("Self-useable has no attached script")
	
	if Input.is_action_just_pressed("interact"):
		if targeted_interactable and not in_menu:
			targeted_interactable.interact()
	
	if Input.is_action_just_released("interact"):
		if is_instance_valid(draggable_being_dragged):
			set_draggable_being_dragged(null)
	
	#if Input.is_action_just_pressed("throw") and is_holding_item("Ruboleum Vial"):
	#	var instance: RigidBody3D = thrown_item.instantiate()
	#	#instance.get_node("Mesh").mesh = held_item
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
	held_item = item_data.item_instance
	if is_holding_hourglass():
		interact_ray.enabled = false
	for mesh in held_item.meshes:
		mesh.layers = 3
	add_child(held_item)
	held_item.position = Vector3.ZERO
	held_item.scale *= item_data.hold_scale_multiplier
	if held_item_data.self_useable:
		held_item.material_overlay.set_shader_parameter("outlineOn", true)
		holding_self_useable.emit(Interactable.Type.NOTE)
	else:
		pass
		#if held_item.material_overlay:
			#held_item.material_overlay.set_shader_parameter("outlineOn", false)
		
	if not first_item_held and is_holding_key() and not debug_no_tutorials:
		Global.ui.hint_popup("Interact with the door while holding the key", 5.0)
		first_item_held = true


func delete_held_item():
	remove_child(held_item)
	inventory_remove_item(held_item_data)
	interact_ray.enabled = true
	held_item_data = null
	held_item = null


func stop_holding_item(play_sound: bool):
	if held_item:
		remove_child(held_item)
	interact_ray.enabled = true
	held_item_data = null
	held_item = null
	if play_sound:
		rucksack_player.play()


func set_held_item_visibility(new_visibility: bool):
	held_item.visible = new_visibility


func set_held_item_global_transform(new_transform: Transform3D):
	held_item.global_transform = new_transform


func set_targeted_interactable(interactable: Interactable):
	targeted_interactable = interactable
	if targeted_interactable:
		interactable_targeted.emit(targeted_interactable.get_interactable_type())
	else:
		var is_holding_self_useable: bool = held_item_data and held_item_data.self_useable
		interactable_untargeted.emit(is_holding_self_useable)


func set_draggable_being_dragged(draggable: Draggable):
	if draggable:
		draggable_local_touch_position = draggable.draggable_body.to_local(interact_ray.get_collision_point())
	else:
		draggable_local_touch_position = Vector3.ZERO
		draggable_being_dragged.set_being_dragged(null)
	draggable_being_dragged = draggable


func play_sound_one_shot(sound: AudioStream):
	noise_player.stream = sound
	noise_player.play()


func is_holding_item(item_name: String):
	return held_item_data and held_item_data.name == item_name


func is_holding_key():
	return held_item_data and held_item_data.name.contains("Key")


func is_holding_journal():
	return held_item_data and held_item_data.name == 'Journal'


func is_holding_hourglass():
	return held_item_data and held_item_data.name == 'Hourglass'


# Check if the standing collision shape collides with the world
func _can_stand():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.set_shape(standing_collision.shape)
	query.transform = standing_collision.global_transform
	query.collision_mask = collision_mask
	var results = space_state.get_rest_info(query)
	
	return results.is_empty()


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
