@tool
extends Node3D

@export var parent_room_global_rot = 0 : set = set_parent_room_global_rot


func _ready():
	if Engine.is_editor_hint():
		for water_plane in get_children():
			var water_mat = water_plane.get_node("plane").mesh.material
			water_mat.set_shader_parameter("parent_room_global_rot", parent_room_global_rot)


func set_parent_room_global_rot(new):
	parent_room_global_rot = new
