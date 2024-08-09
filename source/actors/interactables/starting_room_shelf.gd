@tool
extends Moveable


func _ready() -> void:
	super()
	%note.was_read.connect(set_interactable.bind(true))
