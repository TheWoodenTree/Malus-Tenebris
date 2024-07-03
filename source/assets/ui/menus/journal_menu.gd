extends Menu


func _ready():
	pass


func _exit_tree():
	if Global.player.is_holding_item("Old Journal"):
		Global.player.stop_holding_item(false)


func _on_log_entries_button_pressed():
	Global.ui.display_menu(Global.ui.log_entries_menu)
