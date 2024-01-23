@tool
extends StaticBody3D
class_name TriangleBlock

@export var size: Vector3 = Vector3.ONE : set = _set_size
#@export var nav_walkable: bool = true : set = _set_nav_walkable

@onready var mesh: Mesh = $mesh.mesh
@onready var collision_box = $collision_box


func _ready() -> void:
	mesh.size = size
	collision_box.shape = mesh.create_convex_shape()


func _set_size(new_state):
	size = new_state
	if mesh:
		mesh.size = new_state
	if collision_box:
		collision_box.shape = mesh.create_convex_shape()
