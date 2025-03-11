@tool
extends Moveable

@onready var note = %note

func _ready() -> void:
	super()
	
	if not Engine.is_editor_hint():
		note.was_read.connect(set_interactable.bind(true))
