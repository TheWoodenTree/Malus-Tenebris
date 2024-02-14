@tool
extends Interactable

var player_dragging: bool = false
var player_just_started_dragging: bool = false
var player_just_stopped_dragging: bool = false

var cam_rot_offset: Vector2 = Vector2.ZERO
var angular_velocity_last_frame: Vector3 = Vector3.ZERO
var last_cam_rot_offset: Vector2 = Vector2.ZERO

var pitch_scale_min: float = 1.2
var pitch_scale_max: float = 1.5

var sound_cooldown_timer: Timer = Timer.new()

@onready var draggable_body = $draggable_body
@onready var mesh = $draggable_body/mesh
@onready var interact_area = $draggable_body/interact_area
@onready var creak_player = $creak_player
@onready var close_player = $close_player

@export_range(0, 100) var open_angle: int = 0 : set = set_open_angle

signal moved


func _ready():
	if not Engine.is_editor_hint():
		init(Type.DRAGGABLE, interact_area)
		sound_cooldown_timer.one_shot = true
		sound_cooldown_timer.wait_time = 0.3
		add_child(sound_cooldown_timer)
	draggable_body.rotation_degrees.x = open_angle


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if being_looked_at and interactable or player_dragging:
			mesh.material_overlay.set_shader_parameter("outlineOn", true)
			if not Global.player.cam.is_connected("cam_rotated", add_torque_to_lid):
				Global.player.cam.connect("cam_rotated", add_torque_to_lid)
			outline_on = true
		elif outline_on:
			mesh.material_overlay.set_shader_parameter("outlineOn", false)
			Global.player.cam.disconnect("cam_rotated", add_torque_to_lid)
			outline_on = false


func _physics_process(_delta):
	if not Engine.is_editor_hint():
		var angular_speed: float = draggable_body.angular_velocity.length()
		var angular_speed_last_frame: float = angular_velocity_last_frame.length()
		if not draggable_body.sleeping and abs(angular_speed) > 0.1:
			var large_ang_vel_change: bool = abs(angular_speed - angular_speed_last_frame) > 0.35
			var ang_vel_dir_changed: bool = sign(angular_speed) != sign(angular_speed)
			if (ang_vel_dir_changed or large_ang_vel_change) and sound_cooldown_timer.is_stopped() or player_just_started_dragging:
				if (not ang_vel_dir_changed or player_dragging):# and not creak_player.playing:
					creak_player.play()
					sound_cooldown_timer.start()
					player_just_started_dragging = false
			var effect_scale: float = clamp(abs(angular_speed) / PI, 0, 1.0)
			creak_player.volume_db = lerp(-30.0, -15.0, pow(effect_scale, 1.0))
			creak_player.pitch_scale = lerp(pitch_scale_min, pitch_scale_max, pow(effect_scale, 1.0))
			if not player_dragging and draggable_body.rotation_degrees.x < 1.0:
				creak_player.stop()
				close_player.play()
				draggable_body.rotation.x = 0.0
			elif not player_dragging and draggable_body.rotation_degrees.x > 99.0: # Broken
				draggable_body.rotation.x = 100.0
				draggable_body.angular_velocity = Vector3.ZERO
				
			emit_signal("moved", draggable_body.rotation_degrees.x, true)
		else:
			creak_player.stop()


func interact():
	player_dragging = true
	Global.player.set_draggable_being_dragged(self)


func get_player_z_dist():
	return draggable_body.to_local(Global.player.global_position).rotated(Vector3.UP, draggable_body.rotation.y).z


func set_player_dragging(dragging: bool):
	player_dragging = dragging
	if dragging:
		Global.player.cam.sensitivity_multiplier = Global.player.cam.CAM_DRAG_SENS_MULTIPLIER
		Global.player.door_being_dragged = self
	else:
		player_just_stopped_dragging = true
		await get_tree().create_timer(0.1, false).timeout
		Global.player.cam.sensitivity_multiplier = 1.0


func set_open_angle(open_angle_: int):
	open_angle = open_angle_
	if draggable_body:
		draggable_body.rotation_degrees.x = open_angle


func add_torque_to_lid(offset: Vector2):
	if player_dragging:
		cam_rot_offset = offset
		var torque: Vector3 = Vector3.LEFT * cam_rot_offset.x * 1000.0
		draggable_body.apply_torque(torque.rotated(Vector3.UP, rotation.y))
		Global.player.cam.sensitivity_multiplier = Global.player.cam.CAM_DRAG_SENS_MULTIPLIER
		last_cam_rot_offset = offset
