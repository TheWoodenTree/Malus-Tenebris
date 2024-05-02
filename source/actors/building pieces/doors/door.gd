class_name Door
extends Interactable

var door_shaking: bool = false
var attempt_open_angle: float
var player_on_openable_side: bool = true
var player_dragging: bool = false
var player_just_started_dragging: bool = false
var player_just_stopped_dragging: bool = false
var closed_max_drag_angle: float
var closed: bool
var tutorial_popup_shown: bool = false
var effects_scale: float = 0.0
var player_interact_ray_col_normal: Vector3
var player_facing_dir_xz: Vector2

var cam_rot_offset: Vector2 = Vector2.ZERO
var angular_velocity_last_frame: Vector3 = Vector3.ZERO
var last_cam_rot_offset: Vector2 = Vector2.ZERO

var sound_cooldown_timer: Timer = Timer.new()

var rotation_axis := Vector3.UP

# SET BY DOORWAY SCRIPT
var one_way: bool = false
var locked_by_contraption: bool = false
var open_angle: int
var open_to_angle: int
var angle_offset: int
var open_tween_trans: Tween.TransitionType
var key_name: String
var locked_message: String
var unlocked: bool
var tutorial_popup: bool

var reverse_z_dist: bool = false

@onready var draggable_body = $door_body
@onready var door = $door_body/door
@onready var door_open_player = $door_body/door_open_player
@onready var door_full_open_player = $door_body/door_full_open_player
@onready var door_unlock_player = $door_body/door_unlock_player
@onready var door_close_player = $door_body/door_close_player
@onready var door_attempt_player = $door_body/door_attempt_player
@onready var interact_area = $door_body/interact_area
@onready var key_anim_player = $door_body/key_anim_player
@onready var key = $door_body/key # Parent necessary because of a bug relating to scale when setting global_rotation
@onready var collision_shape = $door_body/collision_shape
@onready var hinge = $door_body/hinge
@onready var mesh = $door_body/door

@export var pitch_scale_min: float = 0.8
@export var pitch_scale_max: float = 1.0

signal moved


func _ready():
	init(Type.DRAGGABLE, interact_area, [mesh])
	sound_cooldown_timer.one_shot = true
	sound_cooldown_timer.wait_time = 0.3
	add_child(sound_cooldown_timer)
	await Global.player.ready
	if interactable and Global.player.is_omnipotent_door_god:
		set_hinge_limits(open_to_angle)


func parent_ready_finished():
	draggable_body.rotation.y = deg_to_rad(open_angle - angle_offset)
	closed_max_drag_angle = 3.0 * sign(open_to_angle - angle_offset)
	closed = abs(draggable_body.rotation.y) <= abs(deg_to_rad(closed_max_drag_angle))
	if unlocked:
		set_hinge_limits(open_to_angle)
	else:
		set_hinge_limits(closed_max_drag_angle)


func _process(_delta: float) -> void:
	if being_looked_at and interactable or player_dragging:
		door.material_overlay.set_shader_parameter("outlineOn", true)
		if not Global.player.cam.is_connected("cam_rotated", add_torque_to_door):
			Global.player.cam.connect("cam_rotated", add_torque_to_door)
		outline_on = true
		if tutorial_popup and not tutorial_popup_shown and Global.player.debug_do_tutorials \
		and Global.player.has_torch and Global.player.torch.is_lit:
			Global.ui.hint_popup("Press and hold 'Left Click' and drag to open the door", 5.0)
			tutorial_popup_shown = true
	elif outline_on:
		door.material_overlay.set_shader_parameter("outlineOn", false)
		Global.player.cam.disconnect("cam_rotated", add_torque_to_door)
		outline_on = false
	
	# Swap interact icons between open door and locked door depending on if door 
	# is locked and player has a key
	if being_looked_at and interactable and not unlocked and \
	Global.player.is_holding_key() and interactable_type == Type.DOOR:
		interactable_type = Type.LOCKED_DOOR
	elif being_looked_at and interactable and not \
	Global.player.is_holding_key() and interactable_type == Type.LOCKED_DOOR:
		interactable_type = Type.DOOR


func _physics_process(_delta):
	if not draggable_body.sleeping and not closed:
		if abs(draggable_body.angular_velocity.y) > 0.1:
			var effect_scale: float = clamp(abs(draggable_body.angular_velocity.y) / PI, 0, 1.0)
			var large_ang_vel_change: bool = abs(draggable_body.angular_velocity.y - angular_velocity_last_frame.y) > 0.35
			var ang_vel_dir_changed: bool = sign(draggable_body.angular_velocity.y) != sign(angular_velocity_last_frame.y)
			if (ang_vel_dir_changed or large_ang_vel_change) and sound_cooldown_timer.is_stopped() or player_just_started_dragging:
				if not ang_vel_dir_changed or player_dragging:
					door_open_player.play()
					sound_cooldown_timer.start()
					player_just_started_dragging = false
					
			door_open_player.volume_db = lerp(-30.0, 0.0, pow(effect_scale, 1.0))
			door_open_player.pitch_scale = lerp(pitch_scale_min, pitch_scale_max, pow(effect_scale, 1.0))
			
			angular_velocity_last_frame = draggable_body.angular_velocity
			
		# Increase damp for angular velocity when the door is close to its hinge limit
		if sign(open_to_angle) == sign(draggable_body.angular_velocity.y):
			var min_damp_angle: float = abs(open_to_angle) - 10.0
			var max_damp_angle: float = abs(open_to_angle)
			var normalized: float = (abs(rad_to_deg(draggable_body.rotation.y)) - min_damp_angle) / (max_damp_angle - min_damp_angle)
			var damping_scale: float = clamp(normalized, 0.0, 1.0) * 10.0
			draggable_body.angular_damp = clamp(5.0 * damping_scale, 5.0, 50.0)
		elif not closed:
			draggable_body.angular_damp = 5.0
			
		# Set door to closed if it isn't being dragged by player and is within the closed angle
		# and angular velocity is closing door
		if not player_dragging and abs(draggable_body.rotation.y) <= deg_to_rad(abs(closed_max_drag_angle)) \
		and sign(draggable_body.angular_velocity.y) == -sign(open_to_angle):
			set_closed(true)
			
		emit_signal("moved", draggable_body.rotation_degrees.y, sign(get_player_z_dist()) == -1)
		
	elif player_dragging and unlocked and abs(draggable_body.rotation.y) >= deg_to_rad(abs(closed_max_drag_angle)):
		set_closed(false)
		
	if abs(draggable_body.angular_velocity.y) < 0.05:
			door_open_player.volume_db = -80.0


func interact():
	if interactable:
		# If the door is one way, check if the player's distance from the door on
		# the z axis (relative to the door) is positive or negative. If the sign 
		# of the distance is opposite the sign of the angle that the door opens to, 
		# the player is on the correct side and can open the door, otherwise not.
		if one_way:
			var player_z_dist = get_player_z_dist()
			player_on_openable_side = sign(player_z_dist) == sign(open_to_angle)
		
		# Player tries to unlock a locked door
		if Global.player.is_holding_key() and player_on_openable_side and not unlocked:
			attempt_unlock()
		
		# Player tries to open the door in the records room but doesn't have a lit torch
		elif tutorial_popup and (not Global.player.has_torch or Global.player.has_torch and not Global.player.torch.is_lit):
			Global.ui.hint_popup("It's too dark; find a light source", 3.0)
		
		# Player drags an unlocked door
		elif (unlocked and player_on_openable_side and locked_message.is_empty()) or Global.player.is_omnipotent_door_god:
			set_player_dragging(true)
		
		# Player tries to open a locked door
		else:
			if not door_shaking:
				door_shaking = true
				door_attempt_player.play()

				var message: String
				if not locked_message.is_empty():
					message = locked_message
				elif player_on_openable_side:
					message = "Need %s Key" % key_name.replace("Lubricated ", "")
				else:
					message = "Blocked from the other side"
				Global.ui.hint_popup(message, 3.0)

				var door_tween = get_tree().create_tween()

				if open_to_angle > 0:
					attempt_open_angle = deg_to_rad(0.5)
				else:
					attempt_open_angle = -deg_to_rad(0.5)

				door_tween.tween_property(draggable_body, "rotation:y", attempt_open_angle, 0.1)
				door_tween.tween_property(draggable_body, "rotation:y", 0, 0.1)
				door_tween.tween_callback(Callable(self,"set").bind("door_shaking", false))


func attempt_unlock():
	var correct_key: bool = Global.player.is_holding_item(key_name + " Key")
	var is_prison_depths_key: bool = Global.player.is_holding_item("Prison Depths Key")
	var anim_name: String
	if is_prison_depths_key:
		anim_name = "insert_rusty_key"
	elif correct_key:
		anim_name = "insert_key"
		if key_name == "Larder":
			Global.player.scripted_event = true
			Global.ui.block_inventory_open = true
	else:
		anim_name = "insert_wrong_key"
	Global.ui.block_inventory_open = true
	if Global.ui.inventory_menu.tutorial_on:
		Global.ui.inventory_menu.set_tutorial_on(false)
	
	var initial_rot: Vector3 = key.global_rotation
	key.global_position = Global.player.held_item_mesh.global_position
	key.global_rotation = Global.player.held_item_mesh.global_rotation
	var initial_pos: Vector3 = key_anim_player.get_animation(anim_name).track_get_key_value(1, 0)
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(key, "global_position", draggable_body.to_global(initial_pos), 0.35)
	tween.parallel().tween_property(key, "global_rotation", initial_rot, 0.35)
	
	key.visible = true
	key.get_node("mesh").layers = 2
	Global.player.set_held_item_visibility(false)
	set_interactable(false)
	
	await tween.finished
	key.get_node("mesh").layers = 1
	key_anim_player.play(anim_name)
	
	# TODO: Remove
	if correct_key and key_name == "Larder":
		get_parent().get_parent().get_parent().get_node("lower_prison_hallway_2/misc/archway_w_door_no_window/door/door_body").rotation_degrees.y = 85.0
		await get_tree().create_timer(1.0, false).timeout
		Global.monster.global_position = get_parent().get_parent().get_node("monster_start_point").global_position
		Global.monster.kitchen_encounter_event()
		await get_tree().create_timer(1.0, false).timeout
		Global.player.cam_look_at_over_time(get_parent().get_parent().get_node("look_at_monster_point").global_position, 3.0)
	
	await key_anim_player.animation_finished
	if correct_key and not is_prison_depths_key:
		Global.player.delete_held_item()
		unlocked = true
		set_hinge_limits(open_to_angle)
		if not Global.player.first_door_unlocked:
			Global.player.first_door_unlocked = false
		# TODO: Remove
		if not key_name == "Larder":
			Global.ui.hint_popup("Unlocked", 2.0)
	else:
		Global.player.set_held_item_global_transform(key.global_transform)
		Global.player.set_held_item_visibility(true)
		key.visible = false
	Global.ui.block_inventory_open = false
	set_interactable(true)


func open():
	set_interactable(false)
	var door_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(open_tween_trans)
	var anim_dur = door_full_open_player.stream.get_length() * (2 - door_full_open_player.pitch_scale)
	door_tween.tween_property(draggable_body, "rotation:y", deg_to_rad(open_to_angle), anim_dur).from(0.0)
	door_full_open_player.play()
	interact_area.set_collision_layer_value(16, false)
	await door_tween.finished
	Global.world.get_node("nav_region").bake_navigation_mesh()
	set_interactable(true)


func set_closed(closed_: bool):
	if closed_ and not closed:
		door_close_player.play()
		door_open_player.stop()
		var tween = get_tree().create_tween()
		tween.tween_property(draggable_body, "rotation_degrees:y", 0.0, 0.1)
	closed = closed_


func set_hinge_limits(angle: float):
	if sign(angle) == 1:
		hinge.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(angle)) 
		hinge.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, 0.0) 
	elif sign(angle) == -1:
		hinge.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 0.0) 
		hinge.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(angle))


func add_torque_to_door(offset: Vector2):
	if player_dragging and (unlocked or Global.player.is_omnipotent_door_god):
		cam_rot_offset = offset
		#var force_direction: Vector2 = Vector2(-cam_rot_offset.y, -cam_rot_offset.x)
		#var test: Vector2 = force_direction.rotated(player_facing_dir_xz.angle_to(Vector2.UP) + PI/2.0)
		#var body_to_hinge: Vector2 = Vector2(door.global_position.x - hinge.global_position.x, door.global_position.z - hinge.global_position.z)
		#var dot: float = body_to_hinge.normalized().dot(test.normalized())
		#var torque: Vector3 = Vector3.UP * dot * 100.0 * force_direction.length()
		#print(force_direction)
		var player_z_dist = get_player_z_dist()
		var torque_sign: int = sign(open_to_angle) * sign(player_z_dist)
		var torque: Vector3 = Vector3.UP * (cam_rot_offset.y + cam_rot_offset.x) * 100.0 * torque_sign
		draggable_body.apply_torque(torque)
		if abs(draggable_body.angular_velocity.y) < 0.075:
			Global.player.cam.can_rotate = false
		else:
			Global.player.cam.can_rotate = true
		Global.player.cam.sensitivity_multiplier = Global.player.cam.CAM_DRAG_SENS_MULTIPLIER
		last_cam_rot_offset = offset


func set_player_dragging(dragging: bool):
	player_dragging = dragging
	if dragging:
		var player_facing_dir: Vector3 = Global.player.get_facing_dir()
		player_facing_dir_xz = Vector2(player_facing_dir.x, player_facing_dir.z).normalized()
		player_just_started_dragging = true
		player_just_stopped_dragging = false
		Global.player.cam.sensitivity_multiplier = Global.player.cam.CAM_DRAG_SENS_MULTIPLIER
		Global.player.set_draggable_being_dragged(self)
	else:
		player_just_started_dragging = false
		player_just_stopped_dragging = true
		await get_tree().create_timer(0.1, false).timeout
		Global.player.cam.sensitivity_multiplier = 1.0
		Global.player.set_draggable_being_dragged(null)
		Global.player.cam.can_rotate = true


func wrong_key_hint_popup():
	Global.ui.hint_popup("Wrong key", 3.0)


func key_needs_lube_hint_popup():
	Global.ui.hint_popup("It's too rusty; perhaps it can be lubricated", 3.0)


func get_player_z_dist():
	var z_dist: float = draggable_body.to_local(Global.player.global_position).rotated(Vector3.UP, draggable_body.rotation.y).z
	# Reverse z_dist for doors that are rotated
	return z_dist if not reverse_z_dist else -1 * z_dist


func get_draggable_body_angle():
	return draggable_body.rotation.y
