extends Interactable


func _on_target():
	if interactable:
		Global.ui.show_hint("I need to figure out what's going\non here before leaving", -1)
		if enable_highlight_sheen:
			enable_highlight_sheen = false
			disable_sheen()


func _on_untarget():
	Global.ui.remove_hint()


func _on_interact() -> void:
	pass
