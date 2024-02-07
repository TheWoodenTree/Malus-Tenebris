extends Control

const BLUR_TIME: float = 0.1

var top_open_menu: Control = null

var inventory_menu: Control
var curr_popup: Control
var curr_popup_wr: WeakRef = null

var inventory_open: bool = false

var ui_hint_popup: Resource = preload("res://source/assets/ui/hint_popup.tscn")
var death_screen_res: Resource = preload("res://source/assets/ui/death_screen.tscn")
var inventory_menu_res: Resource = preload("res://source/assets/ui/inventory.tscn")
var note_menu: Control = preload("res://source/assets/ui/note_menu.tscn").instantiate()

@onready var background = $menus/background
@onready var interact_icon = $cont/interact_icon
@onready var menus = $menus
@onready var block_inventory_open: bool = Global.player.debug_do_tutorials

signal inventory_opened
signal background_changed


func _ready():
	inventory_menu = inventory_menu_res.instantiate()
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
	if Input.is_action_just_pressed("ui_accept") and Global.player.in_menu:
		remove_menu()


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
		emit_signal("inventory_opened")


func set_blur_background(on: bool):
	var blur_tween = get_tree().create_tween()
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
	blur_tween.tween_callback(emit_signal.bind("background_changed"))


func display_menu(menu: Control):
	if menus.num_menus == 0 and menus.add_menu(menu):
		set_blur_background(true)
		Global.unlock_mouse()
		Global.player.in_menu = true


func remove_menu():
	var menu_removed: bool = false
	if menus.num_menus > 0:
		menus.pop_menu()
		menu_removed = true
		
	if menus.num_menus == 0 and menu_removed:
		set_blur_background(false)
		await Global.ui.background_changed
		Global.lock_mouse()
		Global.player.in_menu = false
