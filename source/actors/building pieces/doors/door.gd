@tool
class_name Door
extends Draggable

const KEY_MESH_UNLOCKED_POS = Vector3(0.0, 0.0, 0.25)
const KEY_MESH_UNLOCKED_ROT = Vector3(0.0, 0.0, PI)

@export var blocked: bool = false
@export var key_name: String = ""
@export var locked_message: String = ""
@export var tutorial_popup: bool = false
@export var global_signal_allow_open: String
@export var log_entry_on_first_attempt: LogEntry.LogEntryName

var door_shaking: bool = false
var attempt_open_angle: float
var player_on_openable_side: bool = true
var tutorial_popup_shown: bool = false
var effects_scale: float = 0.0
var player_interact_ray_col_normal: Vector3
var player_facing_dir_xz: Vector2
var being_unlocked := false # For loading from save if saved and quit during unlock anim

var reverse_z_dist: bool = false

var open_attempted: bool = false

@onready var unlocked = key_name.is_empty()

@onready var door = $DraggableBody/Door
@onready var door_full_open_player = $DraggableBody/DoorFullOpenPlayer
@onready var door_unlock_player = $DraggableBody/DoorUnlockPlayer
@onready var door_attempt_player = $DraggableBody/DoorAttemptPlayer
@onready var interact_area = $DraggableBody/InteractArea
@onready var key_anim_player = $DraggableBody/KeyAnimPlayer
@onready var key = $DraggableBody/Key
@onready var key_mesh = $DraggableBody/Key/Mesh
@onready var collision_shape = $DraggableBody/CollisionShape
@onready var mesh = $DraggableBody/Door
@onready var closed_blocking_volume: NavigationObstacle3D = $ClosedBlockingVolume


func _ready():
	super()
	if not Engine.is_editor_hint():
		SaveManager.loaded.connect(_on_loaded_from_save)
		if global_signal_allow_open:
			GlobalSignals.connect(global_signal_allow_open, func(): blocked = false)
	
		if not unlocked and (Global.player and not Global.player.is_omnipotent_door_god):
			set_hinge_limits(-close_threshold_angle, close_threshold_angle)
	
	closed_blocking_volume.affect_navigation_mesh = not unlocked

func _on_target():
	if tutorial_popup and not tutorial_popup_shown and not Global.player.debug_no_tutorials \
	and Global.player.has_torch and Global.player.torch.is_lit:
		Global.ui.hint_popup("Press and hold 'Left Click' and drag to open the door", 5.0)
		tutorial_popup_shown = true
	
	if interactable:
		if not unlocked and Global.player.is_holding_key() and interactable_type == Type.DOOR:
			interactable_type = Type.LOCKED_DOOR
		elif not Global.player.is_holding_key() and interactable_type == Type.LOCKED_DOOR:
			interactable_type = Type.DOOR


func _on_interact() -> void:
	if interactable:
		# Player tries to unlock a locked door
		if Global.player.is_holding_key() and player_on_openable_side and not unlocked:
			attempt_unlock()
		
		# Player tries to open the door in the records room but doesn't have a lit torch
		elif tutorial_popup and (not Global.player.has_torch or Global.player.has_torch and not Global.player.torch.is_lit):
			Global.ui.hint_popup("It's too dark; find a light source", 3.0)
		
		# Player drags an unlocked door
		elif (unlocked and not blocked and locked_message.is_empty()) or Global.player.is_omnipotent_door_god:
			set_being_dragged(Global.player)
			Global.player.set_draggable_being_dragged(self)
		
		# Player tries to open a locked door
		else:
			if not door_shaking:
				door_shaking = true
				door_attempt_player.play()
				
				var message: String
				if not locked_message.is_empty():
					message = locked_message
				elif blocked:
					message = "Blocked by something"
				elif player_on_openable_side:
					message = "Need %s Key" % key_name.replace("Lubricated ", "")
				
				if log_entry_on_first_attempt and not open_attempted:
					JournalManager.add_log_entry(log_entry_on_first_attempt)
				
				Global.ui.hint_popup(message, 3.0)
				
				var door_tween = get_tree().create_tween()
				
				if max_rotation > 0:
					attempt_open_angle = deg_to_rad(0.5)
				else:
					attempt_open_angle = -deg_to_rad(0.5)
				
				door_tween.tween_property(draggable_body, "rotation:y", attempt_open_angle, 0.1)
				door_tween.tween_property(draggable_body, "rotation:y", 0, 0.1)
				door_tween.tween_callback(Callable(self,"set").bind("door_shaking", false))
	open_attempted = true


func attempt_unlock():
	var correct_key: bool = Global.player.is_holding_item(key_name + " Key")
	var is_prison_depths_key: bool = Global.player.is_holding_item("Sump Tunnels Key")
	var anim_name: String
	
	if is_prison_depths_key and key_name == "Lubricated Sump Tunnels":
		anim_name = "insert_rusty_key"
	elif correct_key:
		anim_name = "insert_key"
		if key_name == "Larder":
			Global.player.scripted_event = true
			Global.ui.block_inventory_open = true
		being_unlocked = true
	else:
		anim_name = "insert_wrong_key"
		
	Global.ui.block_inventory_open = true
	if Global.ui.inventory_menu.tutorial_on:
		Global.ui.inventory_menu.set_tutorial_on(false)
	
	var initial_rot: Vector3 = key_mesh.global_rotation
	key_mesh.global_position = Global.player.held_item.global_position
	key_mesh.global_rotation = Global.player.held_item.meshes[0].global_rotation
	var initial_pos: Vector3 = key_anim_player.get_animation(anim_name).track_get_key_value(1, 0)
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(key_mesh, "global_position", key.to_global(initial_pos), 0.35)
	tween.parallel().tween_property(key_mesh, "global_rotation", initial_rot, 0.35)
	
	key_mesh.visible = true
	key_mesh.layers = 3
	Global.player.set_held_item_visibility(false)
	set_interactable(false)
	
	await tween.finished
	key_mesh.layers = 1
	key_anim_player.play(anim_name)
	
	# TODO: Remove
	if correct_key and key_name == "Larder":
		get_parent().get_parent().get_parent().get_node("LowerPrisonHallway2/Misc/ArchwayWDoorNoWindow/Door/DraggableBody").rotation_degrees.y = 85.0
		await get_tree().create_timer(1.0, false).timeout
		Global.monster.global_position = get_parent().get_parent().get_node("MonsterStartPoint").global_position
		Global.monster.kitchen_encounter_event()
		await get_tree().create_timer(1.0, false).timeout
		Global.camera_controller.look_at_over_time(get_parent().get_parent().get_node("LookAtMonsterPoint").global_position, 3.0)
	
	await key_anim_player.animation_finished
	if correct_key and not is_prison_depths_key:
		Global.player.delete_held_item()
		unlock()
		closed_blocking_volume.affect_navigation_mesh = false
		Global.nav_region.bake_navigation_mesh()
	else:
		Global.player.set_held_item_global_transform(key_mesh.global_transform)
		Global.player.set_held_item_visibility(true)
		key_mesh.visible = false
	Global.ui.block_inventory_open = false
	set_interactable(true)


func unlock():
	unlocked = true
	being_unlocked = false
	
	set_hinge_limits(min_rotation, max_rotation)
	
	if not Global.player.first_door_unlocked:
		Global.player.first_door_unlocked = false
	
	if log_entry_on_first_attempt and JournalManager.has_log_entry(log_entry_on_first_attempt):
		JournalManager.remove_log_entry(log_entry_on_first_attempt)


func open():
	set_interactable(false)
	var door_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	var anim_dur = door_full_open_player.stream.get_length() * (2 - door_full_open_player.pitch_scale)
	door_tween.tween_property(draggable_body, "rotation:y", deg_to_rad(max_rotation), anim_dur).from(0.0)
	door_full_open_player.play()
	interact_area.set_collision_layer_value(16, false)
	await door_tween.finished
	Global.world.get_node("NavRegion").bake_navigation_mesh()
	set_interactable(true)


func add_torque_to_draggable_body(offset: Vector2):
	if being_dragged_by and (unlocked or Global.player.is_omnipotent_door_god):
		#var force_direction: Vector2 = Vector2(-offset.y, -offset.x)
		#var test: Vector2 = force_direction.rotated(player_facing_dir_xz.angle_to(Vector2.UP) + PI/2.0)
		#var body_to_hinge: Vector2 = Vector2(door.global_position.x - hinge.global_position.x, door.global_position.z - hinge.global_position.z)
		#var dot: float = body_to_hinge.normalized().dot(test.normalized())
		#var torque: Vector3 = Vector3.UP * dot * 100.0 * force_direction.length()
		#print(force_direction)
		var character_z_dist = get_character_z_dist(being_dragged_by)
		var torque_sign: int = sign(max_rotation) * sign(character_z_dist)
		var torque: Vector3 = Vector3.UP * (offset.y + offset.x) * 100.0 * torque_sign
		draggable_body.apply_torque(torque)
		if being_dragged_by == Global.player:
			Global.camera_controller.sensitivity_multiplier = Global.camera_controller.DRAG_SENS_MULTIPLIER
		last_cam_rot_offset = offset


func _on_player_started_dragging():
	var player_facing_dir: Vector3 = Global.player.get_facing_dir()
	player_facing_dir_xz = Vector2(player_facing_dir.x, player_facing_dir.z).normalized()


func set_closed(closed_: bool):
	if unlocked:
		super(closed_)


func wrong_key_hint_popup():
	Global.ui.hint_popup("Wrong key", 3.0)


func key_needs_lube_hint_popup():
	Global.ui.hint_popup("It's too rusty; perhaps it can be lubricated", 3.0)


func get_character_z_dist(character: CharacterBody3D):
	var z_dist: float = draggable_body.to_local(character.global_position).rotated(Vector3.UP, draggable_body.rotation.y).z
	# Reverse z_dist for doors that are rotated
	return z_dist if not reverse_z_dist else -1 * z_dist


func _on_loaded_from_save():
	if being_unlocked:
		unlock()
		set_interactable(true)
		closed_blocking_volume.affect_navigation_mesh = false
		key_mesh.position = KEY_MESH_UNLOCKED_POS
		key_mesh.rotation = KEY_MESH_UNLOCKED_ROT


func get_save_properties():
	var props: Array[String] = super()
	props.append_array([
		"blocked",
		"tutorial_popup_shown",
		"unlocked",
		"draggable_body:rotation",
		"hinge:angular_limit/upper",
		"hinge:angular_limit/lower",
		"key_mesh:visible",
		"key_mesh:transform",
		"closed",
		"being_unlocked",
		"closed_blocking_volume:affect_navigation_mesh",
	])
	return props
