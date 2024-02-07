@tool
extends Node3D

@export var length: float = 1.0 : set = _set_length

@onready var mesh = $mesh
@onready var collision_shape = $body/collision_shape


func _ready():
	collision_shape.shape.size.z = length
	mesh.mesh.size.z = length


func _set_length(length_):
	length = length_
	if collision_shape:
		collision_shape.shape.size.z = length
	if mesh:
		mesh.mesh.size.z = length
		print(mesh.mesh.size.z)
	
