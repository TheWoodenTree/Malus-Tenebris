extends Camera3D

const CONTROLLER_DZ = 0.25

const BOB_WALK_AMP = 0.05
const BOB_SPRINT_AMP = 0.1
const BOB_WALK_FREQ = (1 / 0.65) * TAU
const BOB_SPRINT_FREQ = BOB_WALK_FREQ#(1 / 0.43) * TAU

var bob_frequency = BOB_WALK_FREQ
var bob_amplitude = BOB_WALK_AMP
var bob_frequency_multiplier: float = 1.0

var controller_sens = 1.0
var controller_offset: Vector2 = Vector2.ZERO
var rotation_offset: Vector2 = Vector2.ZERO
var rotation_last_frame: Vector3 = Vector3.ZERO

var upside_down_mode: bool = false
var mouse_input_received: bool = false
var can_rotate: bool = true

var sensitivity_multiplier: float = 1.0

@onready var starting_pos: Vector3 = position

signal cam_rotated(offset: Vector2)


func _process(_delta: float) -> void:
	_controller_rotate()
	
	#if rotation == rotation_last_frame:
	#	emit_signal("cam_rotated", Vector2.ZERO)
	#rotation_last_frame = rotation
	
	#var offset: Vector2 = Vector2.ZERO
	
	#if controller_offset != Vector2.ZERO:
	#	offset = controller_offset
	#elif mouse_offset != Vector2.ZERO and mouse_input_received:
	#	offset = mouse_offset
	#emit_signal("cam_rotated", offset)
	
	if not Global.player.in_menu:
		if Global.player.global_input_dir != Vector3.ZERO:
			_bob()
		elif Global.player.global_input_dir == Vector3.ZERO:
			_reset_bob()
	
	#if Input.is_action_just_pressed("debug4") and not upside_down_mode:
	#	var rot_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	#	rot_tween.tween_property(self, "rotation:z", PI, 0.25)
	#	#rotation.z = PI
	#	Global.main.set_upside_down_sound(true)
	#	upside_down_mode = true
	#elif Input.is_action_just_pressed("debug4") and upside_down_mode:
	#	var rot_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	#	rot_tween.tween_property(self, "rotation:z", 0.0, 0.25)
	#	#rotation.z = 0.0
	#	Global.main.set_upside_down_sound(false)
	#	upside_down_mode = false
	
	mouse_input_received = false


func _input(event: InputEvent) -> void:
	if Global.mouse_locked and not Global.player.in_menu:
		if event is InputEventMouseMotion:
			var rot_sign = 1
			if upside_down_mode:
				rot_sign = -1
			
			var mouse_y_offset = event.relative.y * Global.mouse_sens * sensitivity_multiplier
			var x_rot_offset = deg_to_rad(mouse_y_offset)
			rotation_offset.x = x_rot_offset
			if can_rotate:
				rotation.x -= x_rot_offset * rot_sign
				rotation.x = clamp(rotation.x, -PI/2, PI/2)
				Global.player.cam_starting_pos.rotation.x -= x_rot_offset * rot_sign
				Global.player.cam_starting_pos.rotation.x = clamp(rotation.x, -PI/2, PI/2)
			
			var mouse_x_offset = event.relative.x * Global.mouse_sens * sensitivity_multiplier
			var y_rot_offset = deg_to_rad(mouse_x_offset)
			rotation_offset.y = y_rot_offset
			if can_rotate:
				rotation.y -= y_rot_offset * rot_sign
				rotation.y = wrapf(rotation.y, 0.0, 2 * PI)
				Global.player.cam_starting_pos.rotation.y -= y_rot_offset * rot_sign
				Global.player.cam_starting_pos.rotation.y = wrapf(rotation.y, 0.0, 2 * PI)
			
			emit_signal("cam_rotated", rotation_offset)
			#emit_signal("cam_rotated", Vector2.ZERO)
		#	mouse_input_received = true


func _bob():
	if Global.player.sprinting:
		bob_frequency = lerp(bob_frequency, BOB_SPRINT_FREQ * bob_frequency_multiplier, 0.05)
		bob_amplitude = lerp(bob_amplitude, BOB_SPRINT_AMP, 0.05)
	else:
		bob_frequency = lerp(bob_frequency, BOB_WALK_FREQ * bob_frequency_multiplier, 0.05)
		bob_amplitude = lerp(bob_amplitude, BOB_WALK_AMP, 0.05)
	
	#print(sin(bob_frequency * (Time.get_ticks_msec() - Global.player.time_when_started_moving) / 1000.0))
	
	#var norm = (bob_frequency - BOB_WALK_FREQ) / (BOB_SPRINT_FREQ - BOB_WALK_FREQ)
	
	var pos_y: float = starting_pos.y + sin(bob_frequency * (Time.get_ticks_msec() - Global.player.time_when_started_moving) / 1000.0) * bob_amplitude
	var pos_x: float = starting_pos.x + sin(bob_frequency / 2.0 * (Time.get_ticks_msec() - Global.player.time_when_started_moving) / 1000.0) * bob_amplitude / 2.0
	var pos_xz_rotated = Vector3(pos_x, 0.0, 0.0).rotated(Vector3.UP, rotation.y)
	position.y = pos_y
	position.x = pos_xz_rotated.x
	position.z = pos_xz_rotated.z

	#look_at(Global.player.cam_look_at_pos.global_position)


func _reset_bob():
	position = lerp(position, starting_pos, 0.025)


func _controller_rotate():
	var axis_vec = Vector2.ZERO
	axis_vec.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vec.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	var rotated: bool = false
	
	if abs(axis_vec.y) > CONTROLLER_DZ:
		rotated = true
		if axis_vec.y > 0:
			axis_vec.y -= CONTROLLER_DZ
		else:
			axis_vec.y += CONTROLLER_DZ
		var joystick_y_offset: float = axis_vec.y * (1 + abs(axis_vec.y)) * controller_sens * sensitivity_multiplier
		var x_rot_offset = deg_to_rad(joystick_y_offset)
		rotation_offset.x = x_rot_offset
		if can_rotate:
			rotation.x -= deg_to_rad(joystick_y_offset)
			rotation.x = clamp(rotation.x, -PI/2, PI/2)
	else:
		controller_offset.y = 0.0
	
	if abs(axis_vec.x) > CONTROLLER_DZ:
		rotated = true
		if axis_vec.x > 0:
			axis_vec.x -= CONTROLLER_DZ
		else:
			axis_vec.x += CONTROLLER_DZ
		var joystick_x_offset: float = axis_vec.x * (1 + abs(axis_vec.x)) * controller_sens * sensitivity_multiplier
		var y_rot_offset = deg_to_rad(joystick_x_offset)
		rotation_offset.y = y_rot_offset
		if can_rotate:
			rotation.y -= deg_to_rad(joystick_x_offset)
			rotation.y = wrapf(rotation.y, 0.0, 2 * PI)
	else:
		controller_offset.x = 0.0
	
	if rotated:
		emit_signal("cam_rotated", rotation_offset)
