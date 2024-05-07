@tool
extends Doorway

const DOOR_POSITION := Vector3(1.125, 0.0, 0.1)

@export_enum("Regular", "Regular With Window", "Polished", "Latched") var door_style: String = "Regular" : set = _set_door_style

static var regular_door: Resource = preload("res://source/actors/building pieces/doors/wood_door_no_window.tscn")
static var regular_door_with_window: Resource = preload("res://source/actors/building pieces/doors/wood_door.tscn")
static var polished_door: Resource = preload("res://source/actors/building pieces/doors/clean_wood_door.tscn")
static var latched_door: Resource = preload("res://source/actors/building pieces/doors/latched_door.tscn")


func _ready():
	update_door()
	super()


func _set_door_style(style_: String):
	door_style = style_
	update_door()


func update_door():
	var new_door: Node3D
	if door:
		remove_child(door)
	match door_style:
		"Regular":
			new_door = regular_door.instantiate()
			_set_style("Prison")
		"Regular With Window":
			new_door = regular_door_with_window.instantiate()
			_set_style("Prison")
		"Polished":
			new_door = polished_door.instantiate()
			_set_style("Polished")
		"Latched":
			new_door = latched_door.instantiate()
			_set_style("Prison")
	new_door.position = DOOR_POSITION
	new_door.name = "door"
	door = new_door
	add_child(door)
