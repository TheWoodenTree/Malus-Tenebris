class_name Player
extends Character

@warning_ignore("unused_signal")
signal crouched
signal interactable_targeted(interactable_type: Interactable.Type)
signal interactable_untargeted

const NOCLIP_SPEED: float = 20.0
const MAX_DIST_FROM_DRAGGABLE: float = 5.0
const MAX_HP = 10.0
const HEARTBEAT_HP_THRESHOLD = 3.333

@export var debug_has_torch: bool = false
@export var debug_no_tutorials: bool = false
@export var is_omnipotent_door_god: bool = false

var health: float = 10.0 :
	set(value):
		health = clamp(value, 0.0, MAX_HP)

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
var held_item_original_rotation: Vector3

var has_torch: bool = false
var in_menu: bool = false
var first_item_picked_up: bool = false
var first_item_held: bool = false
var first_door_unlocked: bool = false
var noclip_on: bool = false
var picked_up_larder_key: bool = false
var scripted_event: bool = false
var in_world: bool = false

var current_state: State

var gulp_sound: AudioStream = preload("res://source/assets/sounds/liquid/gulp.ogg")
var sigh_of_relief_sound: AudioStream = preload("res://source/assets/sounds/player_character/sigh_of_relief.ogg")
var thrown_item: Resource = preload("res://source/actors/misc/thrown_bottle.tscn")
var pain_grunt_stream: AudioStreamRandomizer = preload("res://source/assets/sounds/player_character/pain_grunt.tres")
var acid_burn_sound: AudioStream = preload("res://source/assets/sounds/monster/grunt/acid_burn.wav")

@onready var head = $HeadController
@onready var camera_controller = $HeadController/CameraController
@onready var cam = $HeadController/CameraController/Camera
@onready var torch_cam = $HeadController/CameraController/Camera/ViewportCont/TorchCamViewport/TorchCam
@onready var interact_ray = $HeadController/CameraController/Camera/InteractRaycast
@onready var torch_marker = $HeadController/CameraController/Camera/TorchMarker
@onready var light = $HeadController/CameraController/Camera/BaseLight
@onready var held_item_marker = $HeadController/CameraController/Camera/HeldItemMarker
@onready var noise_player = $HeadController/NoisePlayer
@onready var thrown_item_origin_marker: Marker3D = $HeadController/CameraController/Camera/ThrownItemOriginMarker
@onready var rucksack_player = $RucksackPlayer
@onready var fear_player = $FearPlayer
@onready var fear_pulse_player = $FearPulsePlayer
@onready var hurt_sound_player: AudioStreamPlayer3D = $HeadController/HurtSoundPlayer
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	Global.ui.inventory_opened.connect(stop_holding_item.bind(false))
	state_machine.state_updated.connect(func(state: State): current_state = state)
	
	if debug_has_torch:
		debug_get_torch()
	
	light.omni_range = 3.0
	light.default_energy = 1.0
	
	footstep_timer.wait_time = footstep_walk_interval
	footstep_timer.one_shot = true
	add_child(footstep_timer)
	_load_footsteps()
	
	in_world = true


func _process(delta: float) -> void:
	_handle_input()
	torch_cam.global_transform = cam.global_transform
	if held_item:
		var held_item_pos: Vector3 = held_item_marker.global_position
		held_item.global_position = lerp(held_item.global_position, held_item_pos, delta * 75.0)
		held_item.global_rotation = cam.global_rotation
		held_item.rotate_object_local(Vector3.RIGHT, deg_to_rad(held_item_data.hold_rotation_offset.x))
		held_item.rotate_object_local(Vector3.UP, deg_to_rad(held_item_data.hold_rotation_offset.y))
		held_item.rotate_object_local(Vector3.FORWARD, deg_to_rad(held_item_data.hold_rotation_offset.z))
		held_item.scale = Vector3.ONE * held_item_data.hold_scale_multiplier
	
	global_input_dir = _get_input_dir()
	
	if global_input_dir != Vector3.ZERO and global_input_dir_last_frame == Vector3.ZERO:
		time_when_started_moving = Time.get_ticks_msec()
		camera_controller.bob_timer.seek(0.0)
		camera_controller.bob_timer.play("timer")
	
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
		set_collision_mask_value(5, !noclip_on)
	
	if Input.is_action_just_pressed("interact"):
		if targeted_interactable and not in_menu:
			targeted_interactable.interact()
	
	if Input.is_action_just_released("interact"):
		if is_instance_valid(draggable_being_dragged):
			set_draggable_being_dragged(null)
	
	if Input.is_action_just_pressed("use") and not in_menu and held_item and held_item is SelfUseable:
		held_item = held_item as SelfUseable
		held_item.was_held_before = true
		held_item.use()
		if held_item:
			held_item.was_used = true
		
		#var instance: RigidBody3D = thrown_item.instantiate()
		##instance.get_node("Mesh").mesh = held_item
		#Global.world.add_child(instance)
		#instance.global_rotation = held_item.global_rotation
		#instance.global_position = thrown_item_origin_marker.global_position
		##instance.global_position = 
		##delete_held_item()
		#await get_tree().physics_frame # Two awaits needed for impulse to be correctly applied
		#await get_tree().physics_frame # since it is being applied the frame the instance is added to tree
		#instance.apply_impulse(facing_dir * 15.0 + velocity, Vector3(0.0, 0.185, 0.0))


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
	
	if water_check.is_colliding():
		in_water = true
	else:
		in_water = false
	if footstep_timer.time_left == 0 and moving:
		_play_footstep_sound()


func start_crouch_transition(entering: bool):
	var dist: float = crouch_dist if entering else -crouch_dist
	crouch_tween = create_tween()
	crouch_tween.tween_property(head, "position:y", dist, crouch_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).as_relative()

	get_tree().call_group("player_detection_areas", "set_process_mode", Node.PROCESS_MODE_DISABLED)
	crouching_collision.disabled = not entering
	standing_collision.disabled = entering
	get_tree().call_group("player_detection_areas", "set_process_mode", Node.PROCESS_MODE_INHERIT)


func inventory_add_item(item_data: ItemData):
	Global.ui.inventory_menu.add_item(item_data)
	if not first_item_picked_up:
		first_item_picked_up = true


func inventory_remove_item(item_data: ItemData):
	Global.ui.inventory_menu.remove_item(item_data)


func play_pickup_sound(pickup_sound_player: AudioStreamPlayer3D):
	pickup_sound_player.play()
	await get_tree().create_timer(0.05, false).timeout
	rucksack_player.play()
	# Pickup is freed when this function returns, wait for its sound effect to
	# finish playing
	await pickup_sound_player.finished


func hold_item(item_data: ItemData):
	held_item_data = item_data
	held_item = item_data.item_instance
	for mesh in held_item.meshes:
		mesh.layers = 3
	add_child(held_item)
	held_item.position = Vector3.ZERO
	held_item.scale *= item_data.hold_scale_multiplier
	
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


func is_holding_item(item_name: String):
	return held_item_data and held_item_data.name == item_name


func is_holding_key():
	return held_item_data and held_item_data.name.contains("Key")


func is_holding_journal():
	return held_item_data and held_item_data.name == 'Journal'


func is_holding_hourglass():
	return held_item_data and held_item_data.name == 'Hourglass'


func set_targeted_interactable(interactable: Interactable):
	targeted_interactable = interactable
	if targeted_interactable:
		interactable_targeted.emit(targeted_interactable.get_interactable_type())
	else:
		interactable_untargeted.emit(false)


func set_draggable_being_dragged(draggable: Draggable):
	if draggable:
		draggable_local_touch_position = draggable.draggable_body.to_local(interact_ray.get_collision_point())
	else:
		draggable_local_touch_position = Vector3.ZERO
		draggable_being_dragged.set_being_dragged(null)
	draggable_being_dragged = draggable


func hurt(source: Attack):
	if source is SpitAttack:
		play_sound_one_shot(acid_burn_sound)
		health -= source.damage
	
	if is_zero_approx(health):
		print('ded')
	camera_controller.add_trauma(1.5)
	
	var weight: float = pow(get_normalized_health(), 1.25)
	var multiplier: float = lerp(PostProcessing.PAIN_VIGNETTE_NEAR_DEATH_MUTLIPLIER, PostProcessing.PAIN_VIGNETTE_FULL_HP_MULTIPLIER, weight)
	Global.post_processing.blend_pain_vignette_multiplier(multiplier)
	
	await get_tree().create_timer(0.1, false).timeout
	hurt_sound_player.play()


func heal(amount: float):
	health += amount
	
	var weight: float = pow(get_normalized_health(), 1.25)
	var multiplier: float = lerp(PostProcessing.PAIN_VIGNETTE_NEAR_DEATH_MUTLIPLIER, PostProcessing.PAIN_VIGNETTE_FULL_HP_MULTIPLIER, weight)
	Global.post_processing.blend_pain_vignette_multiplier(multiplier, 1.0)
	Global.post_processing.flash_heal_color_overlay()
	await get_tree().create_timer(0.5, false).timeout
	play_sound_one_shot(sigh_of_relief_sound)


func play_sound_one_shot(sound: AudioStream):
	if not noise_player.playing:
		noise_player.play()
	var test = noise_player.get_stream_playback()
	test.play_stream(sound)
	await noise_player.finished


# Check if the standing collision shape collides with the world
func can_stand():
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


func _get_input_dir():
	var dir = Vector3.ZERO
	dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dir.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	
	return dir.normalized()


func get_normalized_health() -> float:
	return health / MAX_HP


func debug_get_torch():
	Global.torch.interact()
	Global.player.torch.light_torch()
