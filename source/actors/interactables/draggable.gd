@tool 
class_name Draggable
extends Interactable

@export_enum('x', 'y', 'z') var rotation_axis: String = 'x'
@export var max_rotation := 90.0
@export var min_rotation := -90.0
@export_range(-180.0, 180.0, 1.0) var initial_rotation := 0.0 : set = set_initial_rotation
@export var close_threshold_angle := 3.0
@export var default_angular_damp := 5.0
@export var sound_volume_max := -15.0
@export var sound_volume_min := -30.0
@export var sound_pitch_scale_max := 1.2
@export var sound_pitch_scale_min := 0.8

var rotation_axis_vector: Vector3:
	get:
		match rotation_axis:
			'x': return Vector3.RIGHT
			'y': return Vector3.UP
			'z': return Vector3.FORWARD
			_: return Vector3.UP

var being_dragged_by: Character = null
var just_started_being_dragged: bool = false
var just_stopped_being_dragged: bool = false
var closed: bool

var cam_rot_offset: Vector2 = Vector2.ZERO
var angular_velocity_last_frame: Vector3 = Vector3.ZERO
var last_cam_rot_offset: Vector2 = Vector2.ZERO

var sound_cooldown_timer := Timer.new()

@onready var draggable_body: RigidBody3D = $DraggableBody
@onready var move_player: AudioStreamPlayer3D = $DraggableBody/MovePlayer
@onready var close_player: AudioStreamPlayer3D = $DraggableBody/ClosePlayer
@onready var hinge: HingeJoint3D = $Hinge


func _ready():
	super()
	if not Engine.is_editor_hint():
		sound_cooldown_timer.one_shot = true
		sound_cooldown_timer.wait_time = 0.3
		add_child(sound_cooldown_timer)
		set_hinge_limits(min_rotation, max_rotation)
	draggable_body.rotation_degrees[rotation_axis] = initial_rotation
	closed = abs(draggable_body.rotation_degrees[rotation_axis]) <= abs(close_threshold_angle)


func _physics_process(_delta):
	if not Engine.is_editor_hint():
		var angular_speed: float = draggable_body.angular_velocity.length()
		var angular_speed_last_frame: float = angular_velocity_last_frame.length()
		if not draggable_body.sleeping and not closed:
			if abs(angular_speed) > 0.1:
				var large_ang_vel_change: bool = abs(angular_speed - angular_speed_last_frame) > 0.35
				var ang_vel_dir_changed: bool = sign(angular_speed) != sign(angular_speed_last_frame)
				if ((ang_vel_dir_changed or large_ang_vel_change) and sound_cooldown_timer.is_stopped()) or just_started_being_dragged:
					if not ang_vel_dir_changed or being_dragged_by:
						move_player.play()
						sound_cooldown_timer.start()
						just_started_being_dragged = false
						
				var effect_scale: float = clamp(abs(angular_speed) / PI, 0, 1.0)
				move_player.volume_db = lerp(sound_volume_min, sound_volume_max, pow(effect_scale, 1.0))
				move_player.pitch_scale = lerp(sound_pitch_scale_min, sound_pitch_scale_max, pow(effect_scale, 1.0))
				
				angular_velocity_last_frame = draggable_body.angular_velocity
				
				_on_draggable_body_moved()
				
			if sign(max_rotation) == sign(draggable_body.angular_velocity[rotation_axis]):
				var min_damp_angle: float = abs(max_rotation) - 10.0
				var max_damp_angle: float = abs(max_rotation)
				var normalized: float = (abs(get_true_angle()) - min_damp_angle) / (max_damp_angle - min_damp_angle)
				var damping_scale: float = clamp(normalized, 0.0, 1.0) * 10.0
				draggable_body.angular_damp = clamp(5.0 * damping_scale, default_angular_damp, 50.0)
			elif not closed:
				draggable_body.angular_damp = default_angular_damp
			
			if abs(draggable_body.rotation_degrees[rotation_axis]) <= abs(close_threshold_angle) \
			and sign(draggable_body.angular_velocity[rotation_axis]) == -sign(max_rotation):
				set_closed(true)
					
		elif being_dragged_by and closed and abs(draggable_body.rotation_degrees[rotation_axis]) >= abs(close_threshold_angle):
			set_closed(false)
			
		if abs(draggable_body.angular_velocity[rotation_axis]) < 0.05:
			move_player.volume_db = -80.0


func _on_draggable_body_moved():
	pass


func _on_interact() -> void:
	set_being_dragged(Global.player)
	Global.player.set_draggable_being_dragged(self)


func set_player_dragging(dragging: bool):
	if dragging:
		_on_player_started_dragging()
		Global.player.cam.sensitivity_multiplier = Global.player.cam.DRAG_SENS_MULTIPLIER
		if not Global.player.cam.is_connected("cam_rotated", add_torque_to_draggable_body):
			Global.player.cam.connect("cam_rotated", add_torque_to_draggable_body)
	else:
		_on_player_stopped_dragging()
		if Global.player.cam.is_connected("cam_rotated", add_torque_to_draggable_body):
			Global.player.cam.disconnect("cam_rotated", add_torque_to_draggable_body)
		await get_tree().create_timer(0.1, false).timeout
		Global.player.cam.sensitivity_multiplier = 1.0


func set_being_dragged(being_dragged_by_: Character):
	being_dragged_by = being_dragged_by_
	var being_dragged_by_player: bool = being_dragged_by == Global.player
	set_player_dragging(being_dragged_by_player)
	if being_dragged_by:
		if not being_dragged_by_player:
			set_interactable(false)
		just_started_being_dragged = true
		just_stopped_being_dragged = false
	else:
		set_interactable(true)
		just_started_being_dragged = false
		just_stopped_being_dragged = true


func _on_player_started_dragging():
	pass


func _on_player_stopped_dragging():
	pass


func set_initial_rotation(initial_rotation_: float):
	initial_rotation = clamp(initial_rotation_, min_rotation, max_rotation)
	if draggable_body:
		draggable_body.rotation_degrees[rotation_axis] = initial_rotation


func get_true_angle() -> float:
	match rotation_axis:
		'x':
			return -rad_to_deg(atan2(draggable_body.basis.z.y, draggable_body.basis.z.z))
		'y':
			return -rad_to_deg(atan2(draggable_body.basis.x.z, draggable_body.basis.x.x))
		'z':
			return -rad_to_deg(atan2(draggable_body.basis.y.x, draggable_body.basis.y.y))
		_:
			return 0.0


func add_torque_to_draggable_body(offset: Vector2):
	if being_dragged_by:
		cam_rot_offset = offset
		var torque: Vector3 = Vector3.LEFT * cam_rot_offset.x * 1000.0
		draggable_body.apply_torque(torque.rotated(Vector3.UP, rotation.y))
		Global.player.cam.set_sens_mult_to_drag_sens_mult()
		last_cam_rot_offset = offset


func set_hinge_limits(min_angle: float, max_angle: float):
	hinge.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(max_angle)) 
	hinge.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(min_angle)) 


func set_closed(closed_: bool):
	if closed_ and not closed:
		move_player.stop()
		close_player.play()
		var tween = get_tree().create_tween()
		tween.tween_property(draggable_body, "rotation_degrees:" + rotation_axis, 0.0, 0.1)
		tween.tween_callback(func(): draggable_body.sleeping = true)
	closed = closed_
