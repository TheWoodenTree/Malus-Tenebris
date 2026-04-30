@tool
extends Node3D

@export var length: float = 1.0 : set = _set_length

@onready var mesh = $Mesh
@onready var collision_shape = $Body/CollisionShape


func _ready():
	collision_shape.shape.size.z = length
	mesh.mesh.size.z = length


func _set_length(length_):
	length = length_
	if collision_shape:
		collision_shape.shape.size.z = length
	if mesh:
		mesh.mesh.size.z = length
	
