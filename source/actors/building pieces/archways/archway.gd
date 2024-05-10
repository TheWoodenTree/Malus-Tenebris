@tool
class_name Archway
extends Node3D

@export var length: float = 1.0 : set = _set_length
@export var xy_scale: Vector2 = Vector2.ONE : set = _set_xy_scale
@export_enum("Prison", "Polished") var style: String = "Prison" : set = _set_style
@export var has_frame: bool = true : set = _set_has_frame

var archway: MeshInstance3D = null
var frame: MeshInstance3D = null
var frame2: MeshInstance3D = null
var static_body: StaticBody3D = null

static var prison_bricks_mat: StandardMaterial3D = load("res://source/assets/materials/bricks/bricks.tres")
static var prison_frame_mat: StandardMaterial3D = load("res://source/assets/materials/bricks/rough_bricks.tres")
static var polished_bricks_mat: StandardMaterial3D = load("res://source/assets/materials/bricks_2/bricks_2.tres")
static var polished_frame_mat: StandardMaterial3D = load("res://source/assets/materials/white_bricks/white_bricks.tres")


func _ready() -> void:
	archway = find_child("archway")
	frame = find_child("frame")
	static_body = find_child("static_body")
	if archway:
		archway.scale = Vector3(xy_scale.x, xy_scale.y, length)
	if static_body:
		static_body.scale = Vector3(xy_scale.x, xy_scale.y, length)
	update_style()


func _set_length(state):
	length = state
	if archway:
			archway.scale = Vector3(xy_scale.x, xy_scale.y, length)
	if static_body:
		static_body.scale = Vector3(xy_scale.x, xy_scale.y, length)


func _set_xy_scale(new_scale):
	xy_scale = new_scale
	if archway:
			archway.scale = Vector3(xy_scale.x, xy_scale.y, length)
	if static_body:
		static_body.scale = Vector3(xy_scale.x, xy_scale.y, length)


func _set_style(style_: String):
	style = style_
	update_style()


func update_style():
	var archway_mat: StandardMaterial3D
	var frame_mat: StandardMaterial3D
	match style:
		"Prison":
			archway_mat = prison_bricks_mat
			frame_mat = prison_frame_mat
		"Polished":
			archway_mat = polished_bricks_mat
			frame_mat = polished_frame_mat
	if archway:
		archway.mesh.surface_set_material(0, archway_mat)
	if frame:
		frame.mesh.surface_set_material(0, frame_mat)


func _set_has_frame(has_frame_: bool):
	has_frame = has_frame_
	update_has_frame()


func update_has_frame():
	if has_frame:
		frame.visible = true
