extends Door

var latch_locked: bool = false

@onready var latch = $door_body/door_latch


func _ready():
	super()
	latch.parent_door = self
	latch.set_interactable(open_angle < closed_max_drag_angle)


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
