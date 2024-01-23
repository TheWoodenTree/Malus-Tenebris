@tool
extends Node3D

@onready var mesh = $mesh


func _ready():
	var value: float = randf_range(90.0, 180.0)
	mesh.get_surface_override_material(0).albedo_color = Color(value, value, value)
