extends Interactable

var can_crank: bool = true
var being_dragged: bool = false
var just_stopped_being_dragged: bool = false
var connected_node: Node3D
var last_cam_offset: Vector2 = Vector2.ZERO
var last_3_mouse_positions: Array[Vector2] = []
var local_mouse_position: Vector2 = Vector2.ZERO

@onready var crank_anim_player = $CrankAnimPlayer
@onready var rotating_body = $RotatingBody
@onready var crank = $RotatingBody/Crank
@onready var chain_player = $ChainPlayer
@onready var static_chain_1_mat: StandardMaterial3D = $StaticChain.get_node("Mesh").mesh.surface_get_material(0)
@onready var static_chain_2_mat: StandardMaterial3D = $StaticChain2.get_node("Mesh").mesh.surface_get_material(0)

@export var connected_node_name: String
@export var has_crank: bool = false
@export var is_broken: bool = false


func _enter_tree():
	await get_parent().ready
	if not connected_node_name.is_empty():
		connected_node = get_parent().get_node("%" + connected_node_name)
	if connected_node:
		connected_node.connect("finished", set.bind("can_crank", false))


func _ready():
	super()
	crank.visible = has_crank
	if has_crank:
		crank.position.x = -0.15
	await Global.player.ready
	if interactable:
		Global.camera_controller.connect("cam_rotated", add_torque_to_handle)


func _physics_process(_delta):
	if not rotating_body.sleeping and can_crank:
		#if not test and being_dragged:
		#	chain_player.play()
		#	test = true
		rotating_body.angular_velocity.z = clampf(rotating_body.angular_velocity.z, -PI, PI)
		var uv_offset: float = rotating_body.angular_velocity.length() * 0.01
		static_chain_1_mat.uv1_offset.y += uv_offset
		static_chain_2_mat.uv1_offset.y -= uv_offset
		if connected_node:
			connected_node.on_winch_turn(rotating_body.angular_velocity.z)
	elif not rotating_body.freeze:
		if chain_player.playing:
			chain_player.stop()
		rotating_body.angular_velocity = Vector3.ZERO


func _on_interact() -> void:
	if interactable:
		if Global.player.is_holding_item(ItemRegistry.ID.WINCH_CRANK) and not has_crank:
			set_interactable(false)
			
			var initial_rot: Vector3 = crank.global_rotation
			var initial_pos: Vector3 = crank_anim_player.get_animation("insert_crank").track_get_key_value(0, 0)
			crank.global_transform = Global.player.held_item.meshes[0].global_transform
			
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property(crank, "global_position", rotating_body.to_global(initial_pos), 0.5)
			tween.parallel().tween_property(crank, "global_rotation", initial_rot, 0.5)
			crank.layers = 3
			crank.force_update_transform()
			
			await get_tree().process_frame
			
			_untarget()
			Global.player.delete_held_item()
			crank.visible = true
			
			await tween.finished
			crank.layers = 1
			crank_anim_player.play("insert_crank")
			
			await crank_anim_player.animation_finished
			has_crank = true
			set_interactable(true)
		elif has_crank:
			if not is_broken:
				crank_anim_player.play("crank")
				get_parent().get_node("%" + connected_node_name).interact()
				set_interactable(false)
				#being_dragged = true
			else:
				Global.ui.show_hint("It won't budge", 3.0)
		else:
			Global.ui.show_hint("It's missing a crank", 3.0)


func add_torque_to_handle(offset: Vector2):
	if being_dragged and can_crank:
		rotating_body.freeze = false
		#if not chain_player.playing:
		#	chain_player.play()
		var angle_to_last_offset: float = offset.angle_to(last_cam_offset)
		angle_to_last_offset *= sign(offset.cross(last_cam_offset))
		
		var delta_offset_length: float = abs(offset - last_cam_offset).length()
		var min_length: float = 0.01
		var max_length: float = 0.025
		var norm_delta_offset_length: float = max((delta_offset_length - min_length), 0.0) / (max_length - min_length)
		norm_delta_offset_length = clamp(norm_delta_offset_length, 0.0, 1.0)
		var min_angle: float = PI / lerp(48.0, 24.0, norm_delta_offset_length)
		if abs(angle_to_last_offset) > min_angle:
			var torque: Vector3 = Vector3.BACK * -(abs(offset.x) + abs(offset.y)) * 150.0
			rotating_body.apply_torque(torque)
		Global.camera_controller.sensitivity_multiplier = Global.camera_controller.DRAG_SENS_MULTIPLIER
		last_cam_offset = offset


func set_player_dragging(dragging: bool):
	being_dragged = dragging
	if dragging:
		Global.camera_controller.sensitivity_multiplier = Global.camera_controller.DRAG_SENS_MULTIPLIER
	else:
		#local_mouse_position = Vector2.ZERO
		#last_3_mouse_positions.clear()
		just_stopped_being_dragged = true
		await get_tree().create_timer(0.1, false).timeout
		Global.camera_controller.sensitivity_multiplier = 1.0


func _on_chain_player_finished():
	if not rotating_body.sleeping:
		chain_player.play()


func get_save_properties():
	var props: Array[String] = super()
	props.append_array([
		"can_crank",
		"has_crank",
		"is_broken",
		"crank:visible",
		"crank:position",
	])
	return props
