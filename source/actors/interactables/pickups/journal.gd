extends Pickup


func _enter_tree():
	if being_held:
		await get_tree().create_timer(0.35, false).timeout
		
		if Global.ui.menus.open_menus.has(Global.ui.journal_menu):
			return
		
		Global.ui.display_menu(Global.ui.journal_menu)


func _on_target():
	Global.ui.hint_popup("Press 'Left Click' to interact with highlighted objects", -1)


func _on_untarget():
	Global.ui.hint_remove()


func _on_interact() -> void:
	super()
	GlobalSignals.journal_picked_up.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	Global.ui.hint_popup("Press 'E' to open your inventory", 5.0)
