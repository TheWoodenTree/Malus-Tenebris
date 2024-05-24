extends Interactable

var can_crank: bool = true
var player_dragging: bool = false
var player_just_stopped_dragging: bool = false
var connected_node: Node3D
var last_cam_offset: Vector2 = Vector2.ZERO
var last_3_mouse_positions: Array[Vector2] = []
var local_mouse_position: Vector2 = Vector2.ZERO
var test = false

@onready var interact_area = $interact_area
@onready var crank_anim_player = $crank_anim_player
@onready var rotating_body = $rotating_body
@onready var wheel = $rotating_body/wheel
@onready var chains = $rotating_body/chains
@onready var crank = $rotating_body/crank
@onready var support = $support
@onready var chain_player = $chain_player
@onready var static_chain_1_mat: StandardMaterial3D = $static_chain.get_node("mesh").mesh.surface_get_material(0)
@onready var static_chain_2_mat: StandardMaterial3D = $static_chain2.get_node("mesh").mesh.surface_get_material(0)

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
	init(Type.MISC, interact_area, [wheel, chains, support])
	crank.visible = has_crank
	if has_crank:
		crank.position.x = -0.15
	await Global.player.ready
	if interactable:
		Global.player.cam.connect("cam_rotated", add_torque_to_handle)


func _process(_delta):
	if being_looked_at and interactable:
		wheel.material_overlay.set_shader_parameter("outlineOn", true)
		support.material_overlay.set_shader_parameter("outlineOn", true)
		crank.material_overlay.set_shader_parameter("outlineOn", true)
		outline_on = true
	elif outline_on:
		wheel.material_overlay.set_shader_parameter("outlineOn", false)
		support.material_overlay.set_shader_parameter("outlineOn", false)
		crank.material_overlay.set_shader_parameter("outlineOn", false)


func _physics_process(_delta):
	if not rotating_body.sleeping and can_crank:
		if not test and player_dragging:
			chain_player.play()
			test = true
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


func interact():
	if interactable:
		super()
		if Global.player.is_holding_item("Winch Crank") and not has_crank:
			var initial_rot: Vector3 = crank.global_rotation
			var initial_pos: Vector3 = crank_anim_player.get_animation("insert_crank").track_get_key_value(0, 0)
			crank.global_transform = Global.player.held_item_mesh.global_transform
			
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property(crank, "global_position", rotating_body.to_global(initial_pos), 0.5)
			tween.parallel().tween_property(crank, "global_rotation", initial_rot, 0.5)
			crank.layers = 2
			
			set_interactable(false)
			crank.visible = true
			Global.player.delete_held_item()
			
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
				#player_dragging = true
			else:
				Global.ui.hint_popup("It won't budge", 3.0)
		else:
			Global.ui.hint_popup("It's missing a crank", 3.0)


func add_torque_to_handle(offset: Vector2):
	if player_dragging and can_crank:
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
		Global.player.cam.sensitivity_multiplier = Global.player.cam.CAM_DRAG_SENS_MULTIPLIER
		last_cam_offset = offset


func set_player_dragging(dragging: bool):
	player_dragging = dragging
	if dragging:
		Global.player.cam.sensitivity_multiplier = Global.player.cam.CAM_DRAG_SENS_MULTIPLIER
	else:
		#local_mouse_position = Vector2.ZERO
		#last_3_mouse_positions.clear()
		player_just_stopped_dragging = true
		await get_tree().create_timer(0.1, false).timeout
		Global.player.cam.sensitivity_multiplier = 1.0


func _on_chain_player_finished():
	if not rotating_body.sleeping:
		chain_player.play()
