@tool
extends NavigationObstacle3D

@export var size := Vector3.ONE : set = _set_size
@export var show_volume := true : set = _set_show_volume

@onready var volume_mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	_update_blocker_and_mesh()
	volume_mesh.visible = Engine.is_editor_hint() and show_volume


func _set_size(size_: Vector3):
	size = size_
	_update_blocker_and_mesh()


func _set_show_volume(show_volume_: bool):
	show_volume = show_volume_
	volume_mesh.visible = Engine.is_editor_hint() and show_volume


func _update_blocker_and_mesh():
	var half_x: float = size.x / 2.0
	var half_z: float = size.z / 2.0
	
	var new_vertices := PackedVector3Array([
		Vector3(half_x, 0.0, half_z),
		Vector3(-half_x, 0.0, half_z),
		Vector3(-half_x, 0.0, -half_z),
		Vector3(half_x, 0.0, -half_z),
		])
	
	vertices = new_vertices
	height = size.y
	
	volume_mesh.mesh.size = size
	volume_mesh.position.y = size.y / 2.0
	
	volume_mesh.visible = Engine.is_editor_hint()
