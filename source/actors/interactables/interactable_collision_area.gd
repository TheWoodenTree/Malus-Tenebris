class_name InteractArea
extends Area3D

# Set by whatever anscestor is the interactable associated with this Area3D
var interactable_ancestor: Interactable

signal interacted


func interact():
	interacted.emit()


func get_interactable_type():
	return interactable_ancestor.interactable_type
