@tool
class_name LatchedDoor
extends Door

var latch_locked: bool = false

@onready var latch = $DraggableBody/DoorLatch


func _ready():
	super()
	if not Engine.is_editor_hint() and latch:
		latch.parent_door = self
		latch.set_interactable(initial_rotation < close_threshold_angle)


func open():
	latch.set_interactable(false)
	super()


func set_closed(closed_: bool):
	super(closed_)
	latch.set_interactable(closed_)


func on_latch_toggle(latch_locked_: bool):
	latch_locked = latch_locked_
	# Fully close door when latch is locked in case door is techincally closed
	# but open a few degrees
	if latch_locked:
		var tween = get_tree().create_tween()
		tween.tween_property(draggable_body, "rotation_degrees:y", 0.0, 0.1)
	set_interactable(not latch_locked)


func get_save_properties():
	var props: Array[String] = super()
	props.append_array(["latch_locked"])
	return props
