@tool
extends Moveable

func _ready() -> void:
	super()
	
	if not Engine.is_editor_hint():
		GlobalSignals.journal_picked_up.connect(set_interactable.bind(true))
