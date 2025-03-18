@tool
extends Moveable


func _ready() -> void:
	super()
	GlobalSignals.apothecary_door_closed.connect(func(): enable_highlight_sheen = true; enable_sheen)
