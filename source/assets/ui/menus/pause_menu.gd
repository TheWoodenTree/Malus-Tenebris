extends Menu


func _enter_tree():
	await get_tree().process_frame
	get_tree().paused = true


func _on_continue_button_pressed():
	get_tree().paused = false


func _on_settings_button_pressed():
	Global.ui.menu_manager.display_menu(Global.ui.settings_menu)


func _on_quit_button_pressed():
	Global.ui.are_you_sure_menu.set_label_text(
		"Are you sure you want to quit?\nAny progress since your last save will be lost."
	)
	Global.ui.are_you_sure_menu.set_yes_callback(get_tree().quit)
	Global.ui.menu_manager.display_menu(Global.ui.are_you_sure_menu)


func _on_load_from_last_save_button_pressed() -> void:
	Global.ui.are_you_sure_menu.set_label_text("Are you sure you want to load from your last save?")
	Global.ui.are_you_sure_menu.set_yes_callback(Global.reset_game)
	Global.ui.menu_manager.display_menu(Global.ui.are_you_sure_menu)
