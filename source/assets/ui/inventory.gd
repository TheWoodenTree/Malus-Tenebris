extends Control

const MAX_QUEUE_SIZE = 4
const LEFT = 0
const RIGHT = 1

var item_list: Array[ItemData] = []
var num_slots: int = 9
var queued_scrolls: Array[int] = []
var selected_slot: Node
var slot_scroll_tween: Tween
var requested_item: ItemData = null
var item_on_cursor: ItemData = null
var is_item_on_cursor: bool = false
var block_scroll: bool = false
var tutorial_on: bool = true
var scrolling: bool = false

@onready var slot_cont = $cont/slot_cont
@onready var slot_grid = $cont/slot_cont/slot_grid
@onready var item_slots: Array[Node] = slot_grid.get_children()
@onready var scroll_anim_player = $scroll_anim_player
@onready var slot_scroll_player = $slot_scroll_player
@onready var tutorial_label = $cont/vbox_cont/tutorial_label
@onready var item_name_label = $cont/vbox_cont/item_name_label
@onready var select_slot_frame = $cont/vbox_cont/hbox_cont/select_slot_frame
@onready var item_click_player = $item_click_player

signal item_used


func _enter_tree():
	reset_slot_positions()
	if slot_grid and not slot_grid.get_child(4).button.disabled:
		set_selected_slot(slot_grid.get_child(4))
	else:
		set_selected_slot(null)
	requested_item = null # This is set BEFORE it is set in the request_item func
	if item_name_label:
		if selected_slot and selected_slot.item_data:
			set_item_name_label_text(selected_slot.item_data.name, selected_slot.item_data.count)
		else:
			item_name_label.text = ""

func _ready():
	# Make first slot middle slot up first opening inventory
	move_slot_to_back()
	move_slot_to_back()
	move_slot_to_back()
	move_slot_to_back()
	
	for i in range(0, slot_grid.get_child_count()):
		slot_grid.get_child(i).index = i


func _process(_delta):
	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("scroll_up"):
		queue_scroll(LEFT)
	elif Input.is_action_just_pressed("left") or Input.is_action_just_pressed("scroll_down"):
		queue_scroll(RIGHT)
	if is_item_on_cursor:
		_handle_drag()


func add_item(item_data: ItemData):
	for slot in item_slots:
		if not slot.has_item:
			slot.set_item(item_data)
			break
		elif slot.item_data.name == item_data.name:
			slot.item_data.count += item_data.count
			set_item_name_label_text(slot.item_data.name, slot.item_data.count)
			break


func remove_item(item_data: ItemData):
	for i in range(1, item_slots.size() + 1):
		var slot = item_slots[-i]
		if slot.item_data == item_data:
			slot.item_data.count -= 1
			if slot.item_data.count < 1:
				slot.set_item(ItemData.new())
				set_selected_slot(null)
			break


func reset_slot_positions():
	pass


func move_slot_to_front():
	slot_grid.move_child(slot_grid.get_child(0), -1)


func move_slot_to_back():
	slot_grid.move_child(slot_grid.get_child(-1), 0)


func _scroll_slots():
	while not queued_scrolls.is_empty() and is_inside_tree():
		scrolling = true
		var dir = queued_scrolls.back()
		var margin: int
		if dir == LEFT:
			margin = -72
		elif dir == RIGHT:
			margin = 72
		slot_scroll_player.play()
		slot_scroll_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
		slot_scroll_tween.tween_property(slot_cont, "theme_override_constants/margin_left", margin, 0.15)
		slot_scroll_tween.tween_callback(wrap_item_slots.bind(dir))
		slot_scroll_tween.tween_callback(set.bind("slot_scroll_tween", null))
		await slot_scroll_tween.finished
		queued_scrolls.pop_back()
	scrolling = false
	if not is_inside_tree():
		queued_scrolls = []
	set_selected_slot(slot_grid.get_child(4))


func queue_scroll(dir):
	if not block_scroll:
		if queued_scrolls.size() < MAX_QUEUE_SIZE:
			queued_scrolls.push_front(dir)
		if queued_scrolls.size() == 1:
			_scroll_slots()


func attach_item_to_cursor(item_data: ItemData):
	Global.cursor.attached_item.texture = item_data.texture
	item_click_player.stream = item_data.pickup_sound
	item_click_player.play()
	var count: int = item_data.count - 1
	if count < 1:
		selected_slot.set_item_visible(false)
	set_item_name_label_text(item_data.name, count)
	item_on_cursor = item_data
	is_item_on_cursor = true


func remove_item_from_cursor():
	Global.cursor.attached_item.texture = null
	set_item_name_label_text(selected_slot.item_data.name, selected_slot.item_data.count)
	selected_slot.item_texture_rect.visible = true
	block_scroll = false
	item_on_cursor = null
	is_item_on_cursor = false


func _handle_drag():
	if Input.is_action_just_pressed("interact"):
		block_scroll = true
		if tutorial_on and Global.player.debug_do_tutorials:
			tutorial_label.text = "Drag and drop the selected item out of your inventory to hold it"
	if Input.is_action_just_released("interact") or Input.is_action_just_pressed("cancel"):
		if Input.is_action_just_released("interact"): # Scuffed redundant if statement
			var slot_grid_global_rect: Rect2 = Rect2(slot_grid.global_position, slot_grid.size)
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
			var mouse_inside_slot_grid: bool = slot_grid_global_rect.has_point(mouse_pos)
			if not mouse_inside_slot_grid:
				Global.player.hold_item(item_on_cursor)
				Global.ui.set_inventory_open(false)
		remove_item_from_cursor()
		if tutorial_on and Global.player.debug_do_tutorials:
			tutorial_label.text = "Press and hold 'Left Click' on the selected item to pick it up"


func scroll_to_slot(slot: Node):
	queued_scrolls = []
	
	if slot_scroll_tween:
		await slot_scroll_tween.finished
	
	@warning_ignore("integer_division")
	var distance_to_middle: int = num_slots / 2 - slot.get_index()
	var dir: int = -1
	if distance_to_middle > 0:
		dir = RIGHT
	elif distance_to_middle < 0:
		dir = LEFT
	for i in range(0, abs(distance_to_middle)):
		queue_scroll(dir)


func set_selected_slot(slot: Node):
	if selected_slot:
		selected_slot.set_selected(false)
	selected_slot = slot
	if selected_slot:
		selected_slot.set_selected(true)
	else:
		if item_name_label:
			item_name_label.text = ""


func wrap_item_slots(dir):
	if dir == LEFT:
		move_slot_to_front()
	elif dir == RIGHT:
		move_slot_to_back()
	slot_cont.add_theme_constant_override("margin_left", 0)
	var slot_item_data: ItemData = slot_grid.get_child(4).item_data # Problematic line
	set_item_name_label_text(slot_item_data.name, slot_item_data.count)
	if get_viewport():
		get_viewport().update_mouse_cursor_state()
		# Scuffed solution to update slot that is under cursor after animation
		get_viewport().warp_mouse(get_viewport().get_mouse_position() + Vector2.ONE)
		get_viewport().warp_mouse(get_viewport().get_mouse_position() - Vector2.ONE)


func set_item_name_label_text(item_name: String, count: int):
	var name_string: String = item_name
	if count > 1:
		name_string += " x%d" % count
	elif count < 1:
		name_string = ""
	item_name_label.text = name_string


func set_tutorial_on(on: bool):
	tutorial_on = on
	if not on:
		tutorial_label.text = ""


func remove_from_ui():
	queue_free()


func _on_inventory_left_button_button_up():
	queue_scroll(RIGHT)


func _on_inventory_left_button_2_button_up():
	queue_scroll(LEFT)


func _on_scroll_anim_player_animation_started(_anim_name):
	slot_scroll_player.play()


func _on_hold_button_button_up():
	emit_signal("item_used")
	remove_item(selected_slot.item_data)
	Global.ui.set_inventory_open(false)
