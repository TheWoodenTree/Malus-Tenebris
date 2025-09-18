@tool
class_name Doorway
extends Archway

const DOOR_POSITION := Vector3(1.125, 0.0, 0.1)

@export_enum("Do Not Override", "Override True", "Override False") var door_interactable_override: int = 0
@export var door_one_way: bool = false
@export var door_initial_rotation: int = 0 : set = _set_door_rotation
@export var door_open_to_angle: int = 0
@export var door_angle_offset: int = 0
@export var door_open_tween_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var door_key_name: String = ""
@export var door_locked_message: String = ""
@export var door_tutorial_popup: bool = false
@export var door_custom_script: Script
@export_tool_button("Snap Door") var snap_door: Callable = _snap_door

@onready var door = $Door if has_node("Door") else null


func _ready() -> void:
	super()
	child_entered_tree.connect(_on_child_entered_tree)
	if door:
		if not Engine.is_editor_hint():
			# Override interactable script attached to door
			match door_interactable_override:
				1:
					door.set_interactable(true)
				2:
					door.set_interactable(false)
			#door.one_way = door_one_way
			#door.initial_rotation = door_initial_rotation + door_angle_offset
			#door.open_to_angle = door_open_to_angle
			#door.open_tween_trans = door_open_tween_trans
			#door.angle_offset = door_angle_offset
			#door.key_name = door_key_name
			#door.locked_message = door_locked_message
			#door.unlocked = door_key_name.is_empty()
			#door.tutorial_popup = door_tutorial_popup
			#door.parent_ready_finished()
		#else:
		#	door.rotation.y = deg_to_rad(door_initial_rotation + door_angle_offset)


func _on_child_entered_tree(node: Node):
	if node is Door:
		node.position = DOOR_POSITION


func _snap_door():
	for child in get_children():
		if child is Door:
			child.position = DOOR_POSITION
			return


func _set_door_rotation(new_state):
	door_initial_rotation = new_state
	if door:
		door.rotation.y = deg_to_rad(new_state + door_angle_offset)
