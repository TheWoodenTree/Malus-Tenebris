extends Control

var num_menus: int = 0

var open_menus: Array[Control]

@onready var menu_player = $menu_player


func _process(_delta):
	# Menu player uses spatial audio so that reverb can be heard with menu actions,
	# adding a small amount of immersion
	menu_player.global_position = Global.player.global_position


func add_menu(menu: Control):
	if not open_menus.has(menu):
		open_menus.append(menu)
		add_child(menu)
		
		if menu.open_sound:
			menu_player.stream = menu.open_sound
			menu_player.play()
			
		num_menus += 1
		return true
		
	else:
		push_error("Tried opening an already opened menu")
		return false


func pop_menu():
	var menu: Control = open_menus.pop_back()
	menu.on_close()
	
	if menu.close_action == "Remove":
		call_deferred("remove_child", menu)
	elif menu.close_action == "Free":
		menu.queue_free()
	
	if menu.close_sound:
		menu_player.stream = menu.close_sound
		menu_player.play()
		
	num_menus -= 1


func back():
	return open_menus.back()
