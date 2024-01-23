@tool
extends Node3D

@onready var ash = $ash

@export var ash_visible: bool = true : set = _set_ash_visible


func _ready():
	ash.visible = ash_visible


func _set_ash_visible(new_ash_visible: bool):
	ash_visible = new_ash_visible
	if ash:
		ash.visible = new_ash_visible
