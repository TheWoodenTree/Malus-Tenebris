extends Control

const BLUR_TIME: float = 0.1

var inventory_menu: Control
var curr_popup: Control
var curr_popup_wr: WeakRef = null

var inventory_open: bool = false
var block_inventory_open: bool = false

var ui_hint_popup: Resource = preload("res://source/assets/ui/hint_popup.tscn")
var death_screen_res: Resource = preload("res://source/assets/ui/death_screen.tscn")
var inventory_menu_res: Resource = preload("res://source/assets/ui/inventory.tscn")

@onready var background = $background
@onready var interact_icon = $cont/interact_icon

signal background_changed


func _ready():
	inventory_menu = inventory_menu_res.instantiate()
	add_child(inventory_menu)
	remove_child(inventory_menu)


func _process(_delta):
	$Label.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("debug3") and has_node("death_screen"):
		remove_child(get_node("death_screen"))
	if Input.is_action_just_pressed("toggle_inventory"):
		set_inventory_open(not inventory_open)
	if Input.is_action_just_pressed("ui_accept") and Global.player.in_menu:
		var remove_idx = get_child_count() - 1
		get_child(remove_idx).remove_from_ui()


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
	
	# Return is dur is negative to allow popups that will stay on the screen
	if dur < 0:
		return
	
	await get_tree().create_timer(dur, false).timeout
	
	# Ensure this popup was not freed by another call to this function before
	# this popup frees itself
	if popup_wr and popup_wr.get_ref():
		popup.disappear()


func set_inventory_open(is_open: bool):
	if not block_inventory_open:
		if is_open:
			if inventory_menu.is_inside_tree():
				get_tree().paused = true
				push_error("Inventory tried to open when it was already open")
			add_child(inventory_menu)
			Global.unlock_mouse()
			set_blur_background(true)
			if Global.player.held_item:
				Global.player.stop_holding_item(false)
		elif not is_open:
			if not inventory_menu.is_inside_tree():
				get_tree().paused = true
				push_error("Inventory tried to close when it was already closed")
			if inventory_menu.is_item_on_cursor:
				inventory_menu.remove_item_from_cursor()
			call_deferred("remove_child", inventory_menu)
			Global.lock_mouse()
			set_blur_background(false)
		Global.player.in_menu = is_open
		Global.player.rucksack_player.play()
		inventory_open = is_open


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


func display_screen(screen_res: Resource):
	var screen = screen_res.instantiate()
	add_child(screen)
