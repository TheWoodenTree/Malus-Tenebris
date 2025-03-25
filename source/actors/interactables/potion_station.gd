extends Interactable

@onready var mesh = $Mesh
@onready var interact_area = $InteractArea


func interact():
	Global.ui.hint_popup("(Not implemented)", 3.0)
