@tool
extends OccluderInstance3D

var verticies: PackedVector3Array
var indicies: PackedInt32Array
var index: int = 0

func _ready():
	if Engine.is_editor_hint():
		visible = false
	else:
		visible = true


func bake_occluder():
	index = 0
	occluder = ArrayOccluder3D.new()
	for child in get_parent().get_children():
		recursive()


func recursive():
	for child in get_children():
		if child is MeshInstance3D and child.mesh:
			for face in child.mesh.get_faces():
				index += 1
				verticies.append(face)
				indicies.append(index)
		recursive()
