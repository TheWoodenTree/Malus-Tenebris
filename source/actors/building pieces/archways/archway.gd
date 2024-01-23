@tool
extends Node3D
class_name Archway

var archway: MeshInstance3D = null
var static_body: StaticBody3D = null

@export var length: float = 1.0 : set = _set_length
@export var xy_scale: Vector2 = Vector2.ONE : set = _set_xy_scale
@export var material: StandardMaterial3D = load("res://source/assets/materials/bricks/bricks.tres") : set = _set_material



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


func _set_material(new_material: StandardMaterial3D):
	material = new_material
	if archway:
		archway.mesh.surface_set_material(0, new_material)


func _ready() -> void:
	archway = find_child("archway")
	static_body = find_child("StaticBody3D")
	if archway:
		archway.scale = Vector3(xy_scale.x, xy_scale.y, length)
	if static_body:
		static_body.scale = Vector3(xy_scale.x, xy_scale.y, length)
	if material and archway:
		archway.mesh.surface_set_material(0, material)
