class_name HintPopupEvent
extends Event

@export_multiline() var text: String


func _execute() -> void:
	Global.ui.show_hint_popup(text)
