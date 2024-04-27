extends Node3D

const BOB_WALK_AMP: float = 0.05
const BOB_SPRINT_AMP: float = 0.1
const BOB_WALK_FREQ: float = (1 / 0.65) * TAU
const BOB_SPRINT_FREQ: float = (1 / 0.43) * TAU
const DEF_CAM_STABILIZE_DIST: float = -3.0

var bob_transition: bool = false

var bob_frequency: float = BOB_WALK_FREQ
var bob_amplitude: float = BOB_WALK_AMP
var bob_speed_multiplier: float = 1.0 : set = _set_bob_speed_multiplier
var bob_transition_end_time: float
var bob_height_last_frame: float = 0.0

var cam_facing_pos: Vector3
var cam_stabilize_pos: Vector3 = Vector3(0.0, 0.0, DEF_CAM_STABILIZE_DIST)
var stabilize_angle: float

@onready var starting_pos: Vector3 = position
@onready var camera = $camera
@onready var bob_timer = $bob_timer


func _process(_delta):
	
	if not Global.player.in_menu and not Global.player.scripted_event:
		if Global.player.global_input_dir == Vector3.ZERO:
			_reset_bob()
		elif Input.is_action_just_pressed("sprint") and not Global.player.crouching:
			_transition_bob(BOB_SPRINT_FREQ, BOB_SPRINT_AMP)
		elif (Input.is_action_just_released("sprint") and not Global.player.crouching) or Input.is_action_just_pressed("crouch"):
			_transition_bob(BOB_WALK_FREQ, BOB_WALK_AMP)
		elif Global.player.global_input_dir != Vector3.ZERO:
			_bob()
	
	#var facing_dir: Vector3 = get_facing_dir()
	#cam_facing_pos = facing_dir * 3.0 + camera.position
	#cam_stabilize_pos = cam_facing_pos - self.position
	#stabilize_angle = -cam_facing_pos.signed_angle_to(cam_stabilize_pos, Vector3.LEFT.rotated(Vector3.UP, camera.rotation.y))
	

func _bob():
	if not bob_transition:
		if Global.player.sprinting and not Global.player.crouching:
			bob_frequency = BOB_SPRINT_FREQ
			bob_amplitude = BOB_SPRINT_AMP
		else:
			bob_frequency = BOB_WALK_FREQ
			bob_amplitude = BOB_WALK_AMP
		
		var pos_y: float = starting_pos.y + sin(bob_frequency * bob_timer.current_animation_position) * bob_amplitude
		var pos_x: float = starting_pos.x + sin(bob_frequency / 2.0 * bob_timer.current_animation_position) * bob_amplitude / 2.0
		var pos_xz_rotated = Vector3(pos_x, 0.0, 0.0).rotated(Vector3.UP, camera.rotation.y)
		position.y = pos_y
		position.x = pos_xz_rotated.x
		position.z = pos_xz_rotated.z


func _transition_bob(frequency: float, amplitude: float):
	var trans_time: float = 0.1
	
	var pos_y: float = starting_pos.y + sin(frequency * (bob_timer.current_animation_position + trans_time)) * amplitude
	var pos_x: float = starting_pos.x + sin(frequency / 2.0 * (bob_timer.current_animation_position + trans_time)) * amplitude / 2.0
	var pos_xz_rotated = Vector3(pos_x, 0.0, 0.0).rotated(Vector3.UP, camera.rotation.y)
	
	bob_transition = true
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", Vector3(pos_xz_rotated.x, pos_y, pos_xz_rotated.z), trans_time)
	
	await tween.finished
	bob_transition = false
	_bob()


func _reset_bob():
	position = lerp(position, starting_pos, 0.025)


func get_facing_dir():
	var vec = Vector3(1.0, 0.0, 0.0).rotated(Vector3.UP, camera.rotation.y)
	var xz_dir = Vector3(0.0, 0.0, -1.0).rotated(Vector3.LEFT, rotation.x).rotated(Vector3.UP, camera.rotation.y)
	var dir = xz_dir.rotated(vec, camera.rotation.x)
	return dir


# TURBO SCUFFED: Using an animation player to track time because I can set the speed scale for the
# time on it. Need to have this so I can slow down the speed of the head bobs. (Tweening the frequency
# causes rapid bobbing briefly which is not intended)
func _set_bob_speed_multiplier(multiplier: float):
	bob_speed_multiplier = multiplier
	bob_timer.speed_scale = bob_speed_multiplier
