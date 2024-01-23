@tool
extends StaticBody3D

@export var steps: int = 1
@export var x_size: float = 1
@export var y_size: float = 1
@export var z_size: float = 1

@onready var mesh = $mesh.mesh
@onready var collision_box = $collision_box.shape


func _ready() -> void:
#	mesh.size = Vector3(x_size, y_size, z_size)
#	collision_box.extents = Vector3(x_size / 2, y_size / 2, z_size / 2)
	pass


func _process(_delta: float) -> void:
#	if Engine.editor_hint:
#		if mesh != null:
#			mesh.size = Vector3(x_size, y_size, z_size)
#		if collision_box != null:
#			collision_box.extents = Vector3(x_size / 2, y_size / 2, z_size / 2)
	pass
