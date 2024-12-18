extends Control

const BLUR_TIME: float = 0.1

var top_open_menu: Control = null

var inventory_menu: Control
var death_screen: Control
var curr_popup: Control
var curr_popup_wr: WeakRef = null

var inventory_open: bool = false

var prologue: Control = preload("res://source/assets/prologue/prologue.tscn").instantiate()
var ui_hint_popup: Resource = preload("res://source/assets/ui/hint_popup.tscn")
var death_screen_res: Resource = preload("res://source/assets/ui/death_screen.tscn")
var inventory_menu_res: Resource = preload("res://source/assets/ui/inventory.tscn")
var are_you_sure_popup: Control = preload("res://source/assets/ui/menus/are_you_sure_popup.tscn").instantiate()
var pause_menu: Control = preload("res://source/assets/ui/menus/pause_menu.tscn").instantiate()
var settings_menu: Control = preload("res://source/assets/ui/menus/settings_menu.tscn").instantiate()
var journal_menu: Control = preload("res://source/assets/ui/menus/journal_menu.tscn").instantiate()
var log_entries_menu: Control = preload("res://source/assets/ui/menus/log_entries_menu.tscn").instantiate()
var found_notes_menu: Control = preload("res://source/assets/ui/menus/found_notes_menu.tscn").instantiate()
var note_menu: Control = preload("res://source/assets/ui/menus/note_menu.tscn").instantiate()
var in_journal_note_menu: Control = preload("res://source/assets/ui/menus/in_journal_note_menu.tscn").instantiate()

@onready var background = $menus/background
@onready var interact_icon = $cont/interact_icon
@onready var draggable_move_progress_bar = $draggable_move_progress_bar
@onready var menus = $menus
@onready var block_inventory_open: bool = false
@onready var generic_audio_player = $generic_audio_player
@onready var button_hover_player = $button_hover_player
@onready var button_up_player = $button_up_player
@onready var button_down_player = $button_down_player
@onready var log_entry_notification: HBoxContainer = $cont/log_entry_notification

signal inventory_opened
signal background_changed


func _ready():
	inventory_menu = inventory_menu_res.instantiate()
	death_screen = death_screen_res.instantiate()
	add_child(inventory_menu)
	remove_child(inventory_menu)


func _process(_delta):
	if Input.is_action_just_pressed("debug3") and has_node("death_screen"):
		remove_child(get_node("death_screen"))
	if Input.is_action_just_pressed("toggle_inventory"):
		if menus.num_menus == 0:
			open_inventory()
		elif menus.back() == inventory_menu:
			remove_menu()
	
	elif Input.is_action_just_pressed("pause"):
		if menus.open_menus.size() > 0 and menus.back() != Global.main.title_screen:
			if menus.back() == pause_menu:
				get_tree().paused = false
			remove_menu()
		elif Global.player.in_world:
			display_menu(pause_menu)
	
	
	#elif Input.is_action_just_pressed("journal"):
	#	display_menu(journal_menu)


func hint_remove():
	if curr_popup_wr and curr_popup_wr.get_ref():
		curr_popup.disappear()


func hint_popup(msg: String, dur: float):
	var popup = ui_hint_popup.instantiate()
	var popup_wr = weakref(popup)
	
	# Free any popup already on screen when this function is called
	if curr_popup_wr and curr_popup_wr.get_ref():
		curr_popup.queue_free()
		
	add_child(popup)
	move_child(popup, 0)
	curr_popup = popup
	curr_popup_wr = weakref(popup)
	popup.appear(msg)
	
	# Return if dur is negative to allow popups that will stay on the screen
	if dur < 0:
		return
	
	await get_tree().create_timer(dur, false).timeout
	
	# Ensure this popup was not freed by another call to this function before
	# this popup frees itself
	if popup_wr and popup_wr.get_ref():
		popup.disappear()


func open_inventory():
	if not block_inventory_open and not Global.player.in_menu:
		display_menu(inventory_menu)
		inventory_opened.emit()


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
	blur_tween.tween_property(background, "color:a", background_alpha, BLUR_TIME)
	blur_tween.parallel().tween_property(Global.retro_shader, "shader_parameter/blurAmount", background_blur, BLUR_TIME)
	blur_tween.tween_callback(background_changed.emit)


func toggle_draggable_progress_bar(_on: bool):
	#draggable_move_progress_bar.visible = on
	pass


func display_death_screen():
	if menus.num_menus == 0 and menus.add_menu(death_screen):
		Global.player.in_menu = true


func display_menu(menu: Control):
	var success: bool = menus.add_menu(menu)
	if (menus.num_menus == 1 or menus.front() == Global.main.title_screen) and success:
		set_blur_background(true)
		Global.unlock_mouse()
		Global.player.in_menu = true


func remove_menu():
	var menu_removed: bool = false
	if menus.num_menus > 0:
		if menus.back() == pause_menu:
			get_tree().paused = false
		menus.pop_menu()
		menu_removed = true
		
	if (menus.num_menus == 0 or menus.front() == Global.main.title_screen) and menu_removed:
		set_blur_background(false)
		await Global.ui.background_changed
		if not Global.main.title_screen or menus.front() != Global.main.title_screen:
			Global.lock_mouse()
		Global.player.in_menu = false


func do_prologue():
	add_child(prologue)


func notify_new_log_entry():
	generic_audio_player.play()
	var tween1: Tween = get_tree().create_tween()
	tween1.tween_property(log_entry_notification.material, "shader_parameter/alpha_mult", 1.0, 0.5).from(0.0)
	
	await get_tree().create_timer(7.5, false).timeout
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(log_entry_notification.material, "shader_parameter/alpha_mult", 0.0, 0.5).from(1.0)
