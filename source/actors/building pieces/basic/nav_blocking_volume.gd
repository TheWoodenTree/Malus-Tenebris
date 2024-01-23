@tool
extends Block

func _ready():
	mesh.size = size
	collision_box.extents = size / 2
	if not Engine.is_editor_hint():
		mesh.visible = false
