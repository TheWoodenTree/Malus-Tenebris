@tool
extends Archway

@export_category("Door 1")
@export_enum("Do Not Override", "Override True", "Override False") var door1_interactable_override: int = 0
@export var door1_one_way: bool = false
@export var door1_open_angle: int = 0 : set = _set_door1_rotation
@export var door1_open_to_angle: int = 0
@export var door1_angle_offset: int = 0
@export var door1_open_tween_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var door1_key_name: String = ""
@export var door1_locked_message: String = ""
@export var door1_tutorial_popup: bool = false

@export_category("Door 2")
@export_enum("Do Not Override", "Override True", "Override False") var door2_interactable_override: int = 0
@export var door2_one_way: bool = false
@export var door2_open_angle: int = 0 : set = _set_door2_rotation
@export var door2_open_to_angle: int = 0
@export var door2_angle_offset: int = 0
@export var door2_open_tween_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var door2_key_name: String = ""
@export var door2_locked_message: String = ""
@export var door2_tutorial_popup: bool = false

@onready var door1 = $door1
@onready var door2 = $door2
@onready var door1_body = $door1/door_body
@onready var door2_body = $door2/door_body


func _ready():
	super()
	if not Engine.is_editor_hint():
		# Override interactable script attached to door
		match door1_interactable_override:
			1:
				door1.set_interactable(true)
			2:
				door1.set_interactable(false)
		door1.one_way = door1_one_way
		door1.open_angle = door1_open_angle + door1_angle_offset
		door1.open_to_angle = door1_open_to_angle
		door1.open_tween_trans = door1_open_tween_trans
		door1.angle_offset = door1_angle_offset
		door1.key_name = door1_key_name
		door1.locked_message = door1_locked_message
		door1.unlocked = door1_key_name.is_empty()
		door1.tutorial_popup = door1_tutorial_popup
		door1.parent_ready_finished()
		
		match door2_interactable_override:
			1:
				door2.set_interactable(true)
			2:
				door2.set_interactable(false)
		door2.one_way = door2_one_way
		door2.open_angle = door2_open_angle + door2_angle_offset
		door2.open_to_angle = door2_open_to_angle
		door2.open_tween_trans = door2_open_tween_trans
		door2.angle_offset = door2_angle_offset
		door2.key_name = door2_key_name
		door2.locked_message = door2_locked_message
		door2.unlocked = door2_key_name.is_empty()
		door2.tutorial_popup = door2_tutorial_popup
		door2.reverse_z_dist = true
		door2.parent_ready_finished()
	else:
		door1_body.rotation.y = deg_to_rad(door2_open_angle + door2_angle_offset)
		door2_body.rotation.y = deg_to_rad(door2_open_angle + door2_angle_offset)


func _set_door1_rotation(new_state):
	door1_open_angle = new_state
	if door1:
		door1_body.rotation.y = deg_to_rad(new_state + door1_angle_offset)


func _set_door2_rotation(new_state):
	door2_open_angle = new_state
	if door2:
		door2_body.rotation.y = deg_to_rad(new_state + door2_angle_offset)
