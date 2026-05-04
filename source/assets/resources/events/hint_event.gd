class_name HintEvent
extends Event

@export var text: String
@export var duration: float


func _execute() -> void:
	Global.ui.show_hint(text, duration)
