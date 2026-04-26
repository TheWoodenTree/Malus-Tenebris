extends Interactable


func _on_target():
	if interactable:
		Global.ui.hint_popup("I need to figure out what's going\non here before leaving", -1)
		if enable_highlight_sheen:
			enable_highlight_sheen = false
			disable_sheen()


func _on_untarget():
	Global.ui.hint_remove()


func _on_interact() -> void:
	pass
