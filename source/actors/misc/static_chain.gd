@tool
extends Node3D

@onready var mesh_inst = $mesh
@onready var mesh = $mesh.mesh

@export_range(1, 10) var length: int = 1 : set = _set_length


func _ready():
	mesh_inst.position.y = -float(length) / 2.0
	mesh.size.y = float(length)
	mesh.material.uv1_scale = Vector3(1.0, float(length), 1.0)


func _set_length(new_length):
	length = new_length
	if mesh_inst:
		mesh_inst.position.y = -float(length) / 2.0
	
	if mesh:
		mesh.size.y = float(length)
		mesh.material.uv1_scale = Vector3(1.0, float(length), 1.0)
	
