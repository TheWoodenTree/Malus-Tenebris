@tool
extends LatchedDoor

var closed_before: bool = false


func set_closed(closed_: bool):
	super(closed_)
	if closed_ and not closed_before:
		closed_before = true
		GlobalSignals.apothecary_door_closed.emit()
