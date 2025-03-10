extends Interactable

@onready var mesh = $mesh
@onready var interact_area = $interact_area


func interact():
	Global.ui.hint_popup("(Not implemented)", 3.0)
