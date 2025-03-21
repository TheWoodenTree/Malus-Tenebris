@tool
extends Moveable


func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		GlobalSignals.apothecary_door_closed.connect(func(): enable_highlight_sheen = true; enable_sheen())
