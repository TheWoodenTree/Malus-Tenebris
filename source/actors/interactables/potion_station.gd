extends Interactable

@onready var mesh = $mesh
@onready var interact_area = $interact_area


func _ready():
	init(Type.MISC, interact_area)


func _process(_delta):
	if interactable and being_looked_at:
		mesh.material_overlay.set_shader_parameter("outlineOn", true)
		outline_on = true
	elif outline_on:
		mesh.material_overlay.set_shader_parameter("outlineOn", false)
		outline_on = false


func interact():
	Global.ui.hint_popup("(Not implemented)", 3.0)
