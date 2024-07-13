@tool
class_name Doorway
extends Archway

@export_enum("Do Not Override", "Override True", "Override False") var door_interactable_override: int = 0
@export var door_one_way: bool = false
@export var door_open_angle: int = 0 : set = _set_door_rotation
@export var door_open_to_angle: int = 0
@export var door_angle_offset: int = 0
@export var door_open_tween_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var door_key_name: String = ""
@export var door_locked_message: String = ""
@export var door_tutorial_popup: bool = false
@export var door_custom_script: Script

@onready var door = $door if has_node("door") else null


# Set door custom script before ready so its on_ready vars can be initialized
func _enter_tree():
	if door_custom_script:
		get_node("door").set_script(door_custom_script)


func _ready() -> void:
	super()
	if door:
		if not Engine.is_editor_hint():
			# Override interactable script attached to door
			match door_interactable_override:
				1:
					door.set_interactable(true)
				2:
					door.set_interactable(false)
			door.one_way = door_one_way
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


func _set_door_rotation(new_state):
	door_open_angle = new_state
	if door:
		door.rotation.y = deg_to_rad(new_state + door_angle_offset)
