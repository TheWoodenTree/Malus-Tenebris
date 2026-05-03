class_name MenuManager
extends Control

signal background_changed

var num_menus: int = 0

var open_menus: Array[Control]

var inside_tree: bool = false

@onready var menu_player = $MenuPlayer
@onready var background: ColorRect = $Background


func _process(_delta):
	# Menu player uses spatial audio so that reverb can be heard with menu actions
	if inside_tree or (menu_player.is_inside_tree() and Global.player.is_inside_tree()):
		menu_player.global_position = Global.player.global_position
		inside_tree = true


func display_menu(menu: Control):
	var success: bool = _add_menu(menu)
	if (num_menus == 1 or front() == Global.main.title_screen) and success:
		set_blur_background(true)
		Global.unlock_mouse()
		Global.player.in_menu = true


func remove_menu():
	var menu_removed: bool = false
	if num_menus > 0:
		if back() == Global.ui.pause_menu:
			get_tree().paused = false
		_pop_menu()
		menu_removed = true
		
	if (num_menus == 0 or front() == Global.main.title_screen) and menu_removed:
		set_blur_background(false)
		await background_changed
		if not Global.main.title_screen or front() != Global.main.title_screen:
			Global.lock_mouse()
		Global.player.in_menu = false


func _add_menu(menu: Control):
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


func _pop_menu():
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


func set_blur_background(on: bool):
	var blur_tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var background_alpha: float
	var background_blur: float
	if on:
		background_alpha = 0.75
		background_blur = 0.9
	else:
		background_alpha = 0.0
		background_blur = 0.0
	blur_tween.tween_property(background, "color:a", background_alpha, Global.ui.BLUR_TIME)
	blur_tween.parallel().tween_property(Global.retro_shader, "shader_parameter/blurAmount", background_blur, Global.ui.BLUR_TIME)
	blur_tween.tween_callback(background_changed.emit)


func play_sound_one_shot(stream: AudioStream):
	menu_player.stream = stream
	menu_player.play()
