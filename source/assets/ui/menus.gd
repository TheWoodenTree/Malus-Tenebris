extends Control

var num_menus: int = 0

var open_menus: Array[Control]

var inside_tree: bool = false

@onready var menu_player = $menu_player


func _process(_delta):
	# Menu player uses spatial audio so that reverb can be heard with menu actions
	if inside_tree or (menu_player.is_inside_tree() and Global.player.is_inside_tree()):
		menu_player.global_position = Global.player.global_position
		inside_tree = true


func add_menu(menu: Control):
	if not open_menus.has(menu):
		for open_menu in open_menus:
			open_menu.visible = false
			
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
		
	if not open_menus.is_empty():
		open_menus.back().visible = true
		
	num_menus -= 1


func front():
	return open_menus.front() if not open_menus.is_empty() else null


func back():
	return open_menus.back() if not open_menus.is_empty() else null


func play_sound_one_shot(stream: AudioStream):
	menu_player.stream = stream
	menu_player.play()
