@tool
extends DropdownButton


func _option_selected(option_name: String):
	if selected_option != option_name:
		match option_name:
			"Windowed":
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			"Fullscreen":
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			"Borderless Fullscreen":
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	super(option_name)
