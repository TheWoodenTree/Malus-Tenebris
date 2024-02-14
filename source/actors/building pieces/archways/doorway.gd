@tool
extends Archway

const LATCH_POSITION: Vector3 = Vector3(-1.951, 2.211, 0.196)
const FRAME_LATCH_HOLDER_POSITION: Vector3 = Vector3(-2.439, 2.177, 0.181)

var door_latch: Node3D
var door_frame_latch_holder: Node3D

@export_enum("Do Not Override", "Override True", "Override False") var door_interactable_override: int = 0
@export var door_one_way: bool = false
@export var door_has_latch: bool = false : set = _set_door_has_latch
@export var door_latch_locked: bool = false : set = _set_door_latch_locked
@export var door_open_angle: int = 0 : set = _set_door_rotation
@export var door_open_to_angle: int = 0
@export var door_angle_offset: int = 0
@export var door_open_tween_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var door_key_name: String = ""
@export var door_locked_message: String = ""
@export var door_tutorial_popup: bool = false

@onready var door = $door


func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		# Override interactable script attached to door
		match door_interactable_override:
			1:
				door.set_interactable(true)
			2:
				door.set_interactable(false)
		door.one_way = door_one_way
		door.latch_locked = door_latch_locked
		door.open_angle = door_open_angle + door_angle_offset
		door.open_to_angle = door_open_to_angle
		door.open_tween_trans = door_open_tween_trans
		door.angle_offset = door_angle_offset
		door.key_name = door_key_name
		door.locked_message = door_locked_message
		door.unlocked = door_key_name.is_empty()
		door.tutorial_popup = door_tutorial_popup
		door.parent_ready_finished()
	else:
		door.rotation.y = deg_to_rad(door_open_angle + door_angle_offset)
	_update_door_latch()


func _set_door_latch_locked(door_latch_locked_: bool):
	door_latch_locked = door_latch_locked_
	if is_instance_valid(door_latch):
		door_latch.set_locked(door_latch_locked)


func _set_door_has_latch(door_has_latch_: bool):
	door_has_latch = door_has_latch_
	_update_door_latch()


func _update_door_latch():
	if door_has_latch and door:
		door_latch = load("res://source/actors/interactables/door_latch.tscn").instantiate()
		door_frame_latch_holder = load("res://source/actors/misc/door_frame_latch_holder.tscn").instantiate()
		door.get_node("door_body").add_child(door_latch)
		door.add_child(door_frame_latch_holder)
		door_latch.toggled.connect(door.on_latch_toggle)
		door.toggled_close.connect(door_latch.on_door_close_toggle)
		door_latch.position = LATCH_POSITION
		door_frame_latch_holder.position = FRAME_LATCH_HOLDER_POSITION
		door_latch.set_locked(door_latch_locked)
	elif door:
		if door_latch:
			door_latch.queue_free()
		if door_frame_latch_holder:
			door_frame_latch_holder.queue_free()


func _set_door_rotation(new_state):
	door_open_angle = new_state
	if door:
		door.rotation.y = deg_to_rad(new_state + door_angle_offset)
