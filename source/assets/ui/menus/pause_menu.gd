extends Menu


func _enter_tree():
	get_tree().paused = true


func _process(_delta):
	if Input.is_action_just_pressed("pause") and Global.ui.menus.back() == self:
		Global.ui.remove_menu()
		get_tree().paused = false


func _on_continue_button_pressed():
	Global.ui.remove_menu()
	get_tree().paused = false


func _on_settings_button_pressed():
	Global.ui.display_menu(Global.ui.settings_menu)


func _on_quit_button_pressed():
	Global.ui.display_menu(Global.ui.are_you_sure_popup)

