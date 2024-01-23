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

var cam_rot_offset: Vector2 = Vector2.ZERO
var angular_velocity_last_frame: Vector3 = Vector3.ZERO
var last_cam_rot_offset: Vector2 = Vector2.ZERO

var sound_cooldown_timer: Timer = Timer.new()

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

@onready var door_body = $door_body
@onready var highlight_material = $door_body/door.material_overlay
@onready var door_open_player = $door_body/door_open_player
@onready var door_open_finish_player = $door_body/door_open_finish_player
@onready var door_unlock_player = $door_body/door_unlock_player
@onready var door_close_player = $door_body/door_close_player
@onready var door_attempt_player = $door_body/door_attempt_player
@onready var interact_area = $door_body/interact_area
@onready var key_anim_player = $door_body/key_anim_player
@onready var key = $door_body/key # Parent necessary because of a bug relating to scale when setting global_rotation
@onready var collision_shape = $door_body/collision_shape
@onready var hinge = $door_body/hinge

@export var pitch_scale_min: float = 0.8
@export var pitch_scale_max: float = 1.1

#TODO: STOP DOOR DRAGGING WHEN PLAYER IS CERTAIN DISTANCE FROM DOOR

func _ready():
	init(Type.DRAGGABLE, interact_area)
	sound_cooldown_timer.one_shot = true
	sound_cooldown_timer.wait_time = 0.3
	add_child(sound_cooldown_timer)
	await Global.player.ready
	if interactable and Global.player.is_omnipotent_door_god:
		set_hinge_limits(open_to_angle)


func parent_ready_finished():
	door_body.rotation.y = deg_to_rad(open_angle - angle_offset)
	closed_max_drag_angle = 3.0 * sign(open_to_angle - angle_offset)
	closed = abs(door_body.rotation.y) <= abs(deg_to_rad(closed_max_drag_angle))
	if unlocked:
		set_hinge_limits(open_to_angle)
	else:
		set_hinge_limits(closed_max_drag_angle)


func _process(_delta: float) -> void:
	if being_looked_at and interactable or player_dragging:
		highlight_material.set_shader_parameter("outlineOn", true)
		if not Global.player.cam.is_connected("cam_rotated", add_torque_to_door):
			Global.player.cam.connect("cam_rotated", add_torque_to_door)
		outline_on = true
		if tutorial_popup and not tutorial_popup_shown and Global.player.debug_do_tutorials:
			Global.ui.hint_popup("Press and hold 'Left Click' and drag to open the door", 5.0)
			tutorial_popup_shown = true
	elif outline_on:
		highlight_material.set_shader_parameter("outlineOn", false)
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
	if not door_body.sleeping and not closed:
		#print(door_body.rotation_degrees.y)
		if abs(door_body.angular_velocity.y) > 0.1:
			var effect_scale: float = clamp(abs(door_body.angular_velocity.y) / PI, 0, 1.0)
			var large_ang_vel_change: bool = abs(door_body.angular_velocity.y - angular_velocity_last_frame.y) > 0.35
			var ang_vel_dir_changed: bool = sign(door_body.angular_velocity.y) != sign(angular_velocity_last_frame.y)
			if (ang_vel_dir_changed or large_ang_vel_change) and sound_cooldown_timer.is_stopped() or player_just_started_dragging:
				if not ang_vel_dir_changed or player_dragging:
					door_open_player.play()
					sound_cooldown_timer.start()
					player_just_started_dragging = false
					
			# Set door to closed if it isn't being dragged by player and is within the closed angle
			if not player_dragging and abs(door_body.rotation.y) <= deg_to_rad(abs(closed_max_drag_angle)):
				set_closed(true)
			
			door_open_player.volume_db = lerp(-30.0, 0.0, pow(effect_scale, 1.0))
			door_open_player.pitch_scale = lerp(pitch_scale_min, pitch_scale_max, pow(effect_scale, 1.0))
			
			angular_velocity_last_frame = door_body.angular_velocity
		
		# Increase damp for angular velocity when the door is close to its hinge limit
		if sign(open_to_angle) == sign(door_body.angular_velocity.y):
			var min_damp_angle: float = abs(open_to_angle) - 10.0
			var max_damp_angle: float = abs(open_to_angle)
			var normalized: float = (abs(rad_to_deg(door_body.rotation.y)) - min_damp_angle) / (max_damp_angle - min_damp_angle)
			var damping_scale: float = clamp(normalized, 0.0, 1.0) * 10.0
			door_body.angular_damp = clamp(5.0 * damping_scale, 5.0, 50.0)
		elif not closed:
			door_body.angular_damp = 5.0
		
	elif player_dragging and unlocked:
		set_closed(false)
		
	if abs(door_body.angular_velocity.y) < 0.05:
			door_open_player.volume_db = -80.0


func interact():
	if interactable:
		# If the door is one way, check if the player's distance from the door on
		# the z axis (relative to the door) is positive or negative. If the sign 
		# of the distance is opposite the sign of the angle that the door opens to, 
		# the player is on the correct side and can open the door, otherwise not.
		if one_way:
			var player_z_dist = get_player_z_dist()
			player_on_openable_side = sign(player_z_dist) != sign(open_to_angle)
			
		if Global.player.is_holding_key() and player_on_openable_side and not unlocked:
			attempt_unlock()
		elif (unlocked and player_on_openable_side and locked_message.is_empty()) or Global.player.is_omnipotent_door_god:
			player_dragging = true
			player_just_started_dragging = true
			player_just_stopped_dragging = false
			Global.player.draggable_being_dragged = self
		else:
			if not door_shaking:
				door_shaking = true
				door_attempt_player.play()

				var message: String
				if not locked_message.is_empty():
					message = locked_message
				elif player_on_openable_side:
					message = "Need %s Key" % key_name
				else:
					message = "Locked from the other side"
				Global.ui.hint_popup(message, 3.0)

				var door_tween = get_tree().create_tween()

				if open_to_angle > 0:
					attempt_open_angle = 0.0138*PI
				else:
					attempt_open_angle = -0.0138*PI

				door_tween.tween_property(door_body, "rotation:y", attempt_open_angle, 0.1)
				door_tween.tween_property(door_body, "rotation:y", 0, 0.1)
				door_tween.tween_callback(Callable(self,"set").bind("door_shaking", false))


func attempt_unlock():
	var correct_key: bool = Global.player.is_holding_item(key_name + " Key")
	var is_prison_depths_key: bool = Global.player.is_holding_item("Prison Depths Key")
	var anim_name: String
	if is_prison_depths_key:
		anim_name = "insert_rusty_key"
	elif correct_key:
		anim_name = "insert_key"
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
	tween.tween_property(key, "global_position", door_body.to_global(initial_pos), 0.35)
	tween.parallel().tween_property(key, "global_rotation", initial_rot, 0.35)
	
	key.visible = true
	key.get_node("mesh").layers = 2
	Global.player.set_held_item_visibility(false)
	set_interactable(false)
	
	await tween.finished
	key.get_node("mesh").layers = 1
	key_anim_player.play(anim_name)
	
	await key_anim_player.animation_finished
	if correct_key and not is_prison_depths_key:
		Global.player.delete_held_item()
		unlocked = true
		set_hinge_limits(open_to_angle)
		if not Global.player.first_door_unlocked:
			Global.player.first_door_unlocked = false
	else:
		Global.player.set_held_item_global_transform(key.global_transform)
		Global.player.set_held_item_visibility(true)
		key.visible = false
	Global.ui.block_inventory_open = false
	set_interactable(true)


func open():
	var door_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(open_tween_trans)
	var anim_dur = door_open_player.stream.get_length() * (2 - door_open_player.pitch_scale)
	door_tween.tween_property(self, "rotation:y", deg_to_rad(open_to_angle), anim_dur)
	door_open_player.play()
	interact_area.set_collision_layer_value(16, false)
	set_interactable(false)
	await door_tween.finished
	Global.world.get_node("nav_region").bake_navigation_mesh()


func set_closed(enabled: bool):
	if enabled and not closed:
		door_close_player.play()
		set_hinge_limits(closed_max_drag_angle)
		door_open_player.stop()
		door_body.angular_damp = 200.0
	else:
		set_hinge_limits(open_to_angle)
		door_body.angular_damp = 5.0
	closed = enabled


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
		var player_z_dist = get_player_z_dist()
		var torque_sign: int = sign(open_to_angle) * sign(player_z_dist)
		var torque: Vector3 = Vector3.UP * cam_rot_offset.y * 125.0 * torque_sign
		door_body.apply_torque(torque)
		Global.player.cam.can_rotate = false
		last_cam_rot_offset = offset


func set_player_dragging(dragging: bool):
	player_dragging = dragging
	if dragging:
		Global.player.cam.can_rotate = false
		Global.player.door_being_dragged = self
	else:
		player_just_stopped_dragging = true
		await get_tree().create_timer(0.1, false).timeout
		Global.player.cam.can_rotate = true


func wrong_key_hint_popup():
	Global.ui.hint_popup("Wrong key", 3.0)


func key_needs_lube_hint_popup():
	Global.ui.hint_popup("It's too rusty; perhaps it can be lubricated", 3.0)


func get_player_z_dist():
	return door_body.to_local(Global.player.global_position).rotated(Vector3.UP, door_body.rotation.y).z
