extends Menu


func _enter_tree():
	await get_tree().process_frame
	get_tree().paused = true


func _on_continue_button_pressed():
	Global.ui.remove_menu()
	get_tree().paused = false


func _on_settings_button_pressed():
	Global.ui.display_menu(Global.ui.settings_menu)


func _on_quit_button_pressed():
	Global.ui.display_menu(Global.ui.are_you_sure_popup)
