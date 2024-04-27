extends Camera3D

const CONTROLLER_DZ = 0.25

const SOFT_MOVEMENT_MIN_WEIGHT: float = 0.025
const SOFT_MOVEMENT_MAX_WEIGHT: float = 1.0

const CAM_DRAG_SENS_MULTIPLIER = 0.075

var controller_sens = 1.0
var controller_offset: Vector2 = Vector2.ZERO
var rotation_offset: Vector2 = Vector2.ZERO
var rotation_last_frame: Vector3 = Vector3.ZERO
var target_rotation: Vector3 = rotation

var upside_down_mode: bool = false
var mouse_input_received: bool = false
var can_rotate: bool = true
var bob_transition: bool = false

var sensitivity_multiplier: float = 1.0
var soft_movement_weight: float = SOFT_MOVEMENT_MAX_WEIGHT

@onready var parent = get_parent()
@onready var starting_pos: Vector3 = parent.position

signal cam_rotated(offset: Vector2)


func _process(_delta: float) -> void:
	_controller_rotate()
	
	#if Input.is_action_just_pressed("debug4") and not upside_down_mode:
		#var rot_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		#rot_tween.tween_property(self, "rotation:z", PI, 0.25)
		##rotation.z = PI
		#Global.main.set_upside_down_sound(true)
		#upside_down_mode = true
	#elif Input.is_action_just_pressed("debug4") and upside_down_mode:
		#var rot_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		#rot_tween.tween_property(self, "rotation:z", 0.0, 0.25)
		##rotation.z = 0.0
		#Global.main.set_upside_down_sound(false)
		#upside_down_mode = false
	
	if not Global.player.scripted_event:
		rotation.x = lerp_angle(rotation.x, target_rotation.x, soft_movement_weight)
		rotation.y = lerp_angle(rotation.y, target_rotation.y, soft_movement_weight)
	
	mouse_input_received = false


func _input(event: InputEvent) -> void:
	if Global.mouse_locked and not Global.player.in_menu and not Global.player.scripted_event:
		if event is InputEventMouseMotion:
			var rot_sign = 1
			if upside_down_mode:
				rot_sign = -1
			
			var mouse_y_offset = event.relative.y * Global.mouse_sens * sensitivity_multiplier
			var x_rot_offset = deg_to_rad(mouse_y_offset)
			rotation_offset.x = x_rot_offset
			if can_rotate:
				target_rotation.x -= x_rot_offset * rot_sign
				target_rotation.x = clamp(target_rotation.x, -PI/2, PI/2)
				rotation.x = target_rotation.x
				
			
			var mouse_x_offset = event.relative.x * Global.mouse_sens * sensitivity_multiplier
			var y_rot_offset = deg_to_rad(mouse_x_offset)
			rotation_offset.y = y_rot_offset
			if can_rotate:
				target_rotation.y -= y_rot_offset * rot_sign
				target_rotation.y = wrapf(target_rotation.y, 0.0, TAU)
				rotation.y = target_rotation.y
			
			emit_signal("cam_rotated", rotation_offset / CAM_DRAG_SENS_MULTIPLIER)


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
