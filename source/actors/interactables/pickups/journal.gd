extends Pickup


func _enter_tree():
	if being_held:
		await get_tree().create_timer(0.35, false).timeout
		
		if Global.ui.menu_manager.open_menus.has(Global.ui.journal_menu):
			return
		
		Global.ui.menu_manager.display_menu(Global.ui.journal_menu)


func _on_target():
	Global.ui.show_hint("Press 'Left Click' to interact with highlighted objects", -1)


func _on_untarget():
	Global.ui.remove_hint()


func _on_interact() -> void:
	super()
	GlobalSignals.journal_picked_up.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	Global.ui.show_hint("Press 'E' to open your inventory", 5.0)
