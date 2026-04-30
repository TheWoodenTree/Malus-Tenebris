@tool
extends Moveable

func _ready() -> void:
	super()
	
	if not Engine.is_editor_hint():
		GlobalSignals.cell_note_read.connect(set_interactable.bind(true))
