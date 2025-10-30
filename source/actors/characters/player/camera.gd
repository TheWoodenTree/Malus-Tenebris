extends Node3D

const BOB_CROUCH_AMP: float = 0.06
const BOB_WALK_AMP: float = 0.06
const BOB_SPRINT_AMP: float = 0.12
const BOB_CROUCH_FREQ: float = TAU
const BOB_WALK_FREQ: float = 2.0 * TAU
const BOB_SPRINT_FREQ: float = 3.0 * TAU
const STRAFE_ROLL_WALK_MULT: float = 0.007
const STRAFE_ROLL_SPRINT_MULT: float = 0.015

const BOB_STABILIZATION_SCALE = 0.2

@export var trauma_noise: FastNoiseLite
@export var trauma_speed: float = 1000.0
@export var trauma_max_x: float = 10.0
@export var trauma_max_y: float = 10.0
@export var trauma_max_z: float = 5.0

var trauma: float = 0.0
var trauma_time: float = 0.0
var trauma_reduction_rate: float = 3.0

var initial_rotation := Vector3.ZERO

var bob_transition: bool = false

var bob_frequency: float = BOB_WALK_FREQ
var bob_amplitude: float = BOB_WALK_AMP
var bob_speed_multiplier: float = 1.0 : set = _set_bob_speed_multiplier
var bob_transition_end_time: float
var bob_height_last_frame: float = 0.0
var target_amplitude: float = BOB_WALK_AMP
var target_strafe_roll: float = STRAFE_ROLL_WALK_MULT
var displayed_offset_y: float = 0.0
var displayed_offset_x: float = 0.0
var displayed_strafe_roll_offset: float = 0.0
var phase_last_frame: float = 0.0
var torch_marker_starting_pos: Vector3 = Vector3.ZERO

@onready var starting_pos: Vector3 = position
@onready var starting_rot: Vector3 = rotation
@onready var bob_timer = $BobTimer
@onready var torch_cam: Camera3D = $ViewportCont/TorchCamViewport/TorchCam


func _ready() -> void:
	await Global.player.ready
	torch_marker_starting_pos = Global.player.torch_marker.position


func _process(delta):
	if not Global.player.in_menu and not Global.player.scripted_event:
		if Global.player.global_input_dir == Vector3.ZERO:
			_reset_bob(delta)
		elif Global.player.global_input_dir != Vector3.ZERO:
			_bob(delta)
	
	if not is_zero_approx(trauma):
		trauma_time += delta
		trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
		rotation_degrees.x = initial_rotation.x + trauma_max_x * get_shake_intensity() * get_trauma_noise_from_seed(0)
		rotation_degrees.y = initial_rotation.y + trauma_max_y * get_shake_intensity() * get_trauma_noise_from_seed(1)
		rotation_degrees.z = initial_rotation.z + trauma_max_z * get_shake_intensity() * get_trauma_noise_from_seed(2)
	
	torch_cam.global_transform = global_transform


func _bob(delta):
	if Global.player.sprinting and not Global.player.crouching:
		bob_frequency = BOB_SPRINT_FREQ
		target_amplitude = BOB_SPRINT_AMP
		target_strafe_roll = Global.player.get_input_dir().x * STRAFE_ROLL_SPRINT_MULT
	elif not Global.player.sprinting and Global.player.crouching:
		bob_frequency = BOB_CROUCH_FREQ
		target_amplitude = BOB_CROUCH_AMP
		target_strafe_roll = Global.player.get_input_dir().x * STRAFE_ROLL_WALK_MULT
	else:
		bob_frequency = BOB_WALK_FREQ
		target_amplitude = BOB_WALK_AMP
		target_strafe_roll = Global.player.get_input_dir().x * STRAFE_ROLL_WALK_MULT
	
	var phase: float = bob_frequency * bob_timer.current_animation_position
	var wrapped_phase = fposmod(phase, TAU)
	
	var target_offset_y: float = sin(phase) * target_amplitude
	var target_offset_x: float = sin(phase * 0.5) * target_amplitude * 0.5
	
	displayed_offset_y = lerp(displayed_offset_y, target_offset_y, delta * 8.0)
	displayed_offset_x = lerp(displayed_offset_x, target_offset_x, delta * 8.0)
	displayed_strafe_roll_offset = move_toward(displayed_strafe_roll_offset, target_strafe_roll, delta * 0.1)
	
	position.y = starting_pos.y + displayed_offset_y
	position.x = starting_pos.x + displayed_offset_x
	rotation.x = -displayed_offset_y * BOB_STABILIZATION_SCALE
	rotation.z = sin(phase * 0.5) * target_amplitude * 0.035 + displayed_strafe_roll_offset
	
	# Accounts for the torch being scaled down when held
	Global.player.torch_marker.position.x = torch_marker_starting_pos.x + displayed_offset_x * 0.75
	Global.player.torch_marker.position.y = torch_marker_starting_pos.y + displayed_offset_y * 0.75
	
	if phase_last_frame < 3.0 * PI / 2.0 and wrapped_phase >= 3.0 * PI / 2.0:
		Global.player._play_footstep_sound()
	
	phase_last_frame = wrapped_phase


func _reset_bob(delta):
	displayed_offset_y = lerp(displayed_offset_y, 0.0, delta * 8.0)
	displayed_offset_x = lerp(displayed_offset_x, 0.0, delta * 8.0)
	displayed_strafe_roll_offset = lerp(displayed_strafe_roll_offset, 0.0, delta * 8.0)
	position.y = lerp(position.y, starting_pos.y, delta * 8.0)
	position.x = lerp(position.x, starting_pos.x, delta * 8.0)
	rotation.x = lerp(rotation.x, 0.0, delta * 8.0)
	rotation.z = lerp(rotation.z, 0.0, delta * 8.0)
	Global.player.torch_marker.position.x = lerp(Global.player.torch_marker.position.x, torch_marker_starting_pos.x, delta * 8.0)
	Global.player.torch_marker.position.y = lerp(Global.player.torch_marker.position.y, torch_marker_starting_pos.y, delta * 8.0)


func get_facing_dir():
	var vec = Vector3(1.0, 0.0, 0.0).rotated(Vector3.UP, rotation.y)
	var xz_dir = Vector3(0.0, 0.0, -1.0).rotated(Vector3.LEFT, rotation.x).rotated(Vector3.UP, rotation.y)
	var dir = xz_dir.rotated(vec, rotation.x)
	return dir


# TURBO SCUFFED: Using an animation player to track time because I can set the speed scale for the
# time on it. Need to have this so I can slow down the speed of the head bobs. (Tweening the frequency
# causes rapid bobbing briefly which is not intended)
func _set_bob_speed_multiplier(multiplier: float):
	bob_speed_multiplier = multiplier
	bob_timer.speed_scale = bob_speed_multiplier


func add_trauma(trauma_amount: float):
	trauma = clamp(trauma + trauma_amount, 0.0, 2.5)


func get_trauma_noise_from_seed(seed_: int):
	trauma_noise.seed = seed_
	return trauma_noise.get_noise_1d(trauma_time * trauma_speed)


func get_shake_intensity():
	return trauma * trauma
