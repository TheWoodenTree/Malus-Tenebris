extends Area3D
class_name InteractArea

# Set by whatever anscestor is the interactable associated with this Area3D
var interactable_ancestor: Interactable

signal interacted


func interact():
	emit_signal("interacted")


func get_interactable_type():
	return interactable_ancestor.interactable_type
