class_name Inventory
extends Menu

signal item_attached_to_cursor(item_data: ItemData)

const MAX_QUEUE_SIZE: int = 4
const LEFT: int = 0
const RIGHT: int = 1

var queued_scrolls: Array[int] = []
var selected_slot: ItemSlot
var slot_scroll_tween: Tween
var requested_item: ItemData = null
var block_scroll: bool = false
var tutorial_on: bool = true
var scrolling: bool = false

@onready var slot_cont = $Cont/SlotCont
@onready var slot_grid = $Cont/SlotCont/SlotGrid
@onready var item_slots: Array[Node] = slot_grid.get_children()
@onready var scroll_anim_player = $ScrollAnimPlayer
@onready var slot_scroll_player = $SlotScrollPlayer
@onready var tutorial_label = $Cont/VboxCont/TutorialLabel
@onready var item_name_label = $Cont/VboxCont/ItemNameLabel
@onready var select_slot_frame = $Cont/VboxCont/HboxCont/SelectSlotFrame
@onready var item_click_player = $ItemClickPlayer


func _enter_tree():
	if not is_node_ready():
		await ready
	
	if slot_grid:
		update_slots_item_datas()
		update_slot_hotkey_symbols()
		if not slot_grid.get_child(4).button.disabled:
			set_selected_slot(slot_grid.get_child(4))
		else:
			set_selected_slot(null)
	requested_item = null # This is set BEFORE it is set in the request_item func
	if item_name_label:
		if selected_slot and selected_slot.item_data:
			set_item_name_label_text(selected_slot.item_data.name)
		else:
			item_name_label.text = ""


func _ready():
	update_slots_item_datas()
	if not slot_grid.get_child(0).button.disabled:
		set_selected_slot(slot_grid.get_child(0))
		set_item_name_label_text(selected_slot.item_data.name)
		
	move_slot_to_back()
	move_slot_to_back()
	move_slot_to_back()
	move_slot_to_back()
	
	if not Global.player.debug_no_tutorials:
		tutorial_label.text = "Press and hold 'Left Click' on the selected item to pick it up"
	
	for slot: ItemSlot in slot_grid.get_children():
		slot.button.button_down.connect(_on_slot_button_down.bind(slot))
		slot.button.button_up.connect(_on_slot_button_up.bind(slot))


func _process(_delta):
	if Global.cursor.has_attached_item():
		_handle_drag()


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_action_pressed("right") or event.is_action_pressed("scroll_up"):
			queue_scroll(LEFT)
		elif event.is_action_pressed("left") or event.is_action_pressed("scroll_down"):
			queue_scroll(RIGHT)
		
		var hotkey_actions: Array[String] = [
			"inventory_hotkey_1",
			"inventory_hotkey_2",
			"inventory_hotkey_3",
			"inventory_hotkey_4",
		]
		for action: String in hotkey_actions:
			if event.is_action_pressed(action):
				InventoryManager.add_hotkey(action, selected_slot.item_data.id)
				update_slot_hotkey_symbols()


func update_slot_hotkey_symbols():
	for slot: ItemSlot in slot_grid.get_children():
		if slot.item_data and InventoryManager.hotkeys.values().has(slot.item_data.id):
			slot.hotkey_symbol = InventoryManager.get_hotkey_symbol_from_id(slot.item_data.id)
		else:
			slot.hotkey_symbol = ""


func add_item(item_data: ItemData, slot_number: int):
	slot_grid.get_child(slot_number).set_item(item_data)


func remove_item(slot_number: int):
	slot_grid.get_child(slot_number).set_item(null)


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


func attach_item_to_cursor(item_slot: ItemSlot):
	Global.cursor.attach_item(item_slot.item_data, item_slot)
	item_attached_to_cursor.emit(item_slot.item_data)
	selected_slot.set_item_visible(false)


func remove_item_from_cursor():
	Global.cursor.detatch_item()
	selected_slot.item_texture_rect.visible = true
	block_scroll = false


func _handle_drag():
	if Input.is_action_just_pressed("interact"):
		block_scroll = true
		if tutorial_on and not Global.player.debug_no_tutorials:
			tutorial_label.text = "Drag and drop the selected item out of your inventory to hold it"
	if Input.is_action_just_released("interact") or Input.is_action_just_pressed("cancel"):
		if Input.is_action_just_released("interact"): # Scuffed redundant if statement
			var slot_grid_global_rect: Rect2 = Rect2(slot_grid.global_position, slot_grid.size)
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
			var mouse_inside_slot_grid: bool = slot_grid_global_rect.has_point(mouse_pos)
			if not mouse_inside_slot_grid:
				Global.player.hold_item(Global.cursor.attached_item_data)
				if tutorial_on:
					set_tutorial_on(false)
				Global.ui.remove_menu()
		remove_item_from_cursor()
		if tutorial_on and not Global.player.debug_no_tutorials:
			tutorial_label.text = "Press and hold 'Left Click' on the selected item to pick it up"


func scroll_to_slot(slot: Node):
	queued_scrolls = []
	
	if slot_scroll_tween:
		await slot_scroll_tween.finished
	
	@warning_ignore("integer_division")
	var distance_to_middle: int = InventoryManager.num_slots / 2 - slot.get_index()
	var dir: int = -1
	if distance_to_middle > 0:
		dir = RIGHT
	elif distance_to_middle < 0:
		dir = LEFT
	for i in range(0, abs(distance_to_middle)):
		queue_scroll(dir)


func set_selected_slot(slot: Node):
	selected_slot = slot
	if not selected_slot and item_name_label:
		item_name_label.text = ""


func wrap_item_slots(dir):
	if dir == LEFT:
		move_slot_to_front()
	elif dir == RIGHT:
		move_slot_to_back()
	slot_cont.add_theme_constant_override("margin_left", 0)
	var slot_item_data: ItemData = slot_grid.get_child(4).item_data # Problematic line
	set_item_name_label_text(slot_item_data.name if slot_item_data else "")
	if get_viewport():
		get_viewport().update_mouse_cursor_state()
		# Scuffed solution to update slot that is under cursor after animation
		get_viewport().warp_mouse(get_viewport().get_mouse_position() + Vector2.ONE)
		get_viewport().warp_mouse(get_viewport().get_mouse_position() - Vector2.ONE)


func set_item_name_label_text(item_name: String):
	item_name_label.text = item_name


func set_tutorial_on(on: bool):
	tutorial_on = on
	if not on:
		tutorial_label.text = ""


func on_close():
	if Global.cursor.has_attached_item():
		remove_item_from_cursor()


func _on_inventory_left_button_button_up():
	queue_scroll(RIGHT)


func _on_inventory_left_button_2_button_up():
	queue_scroll(LEFT)


func _on_scroll_anim_player_animation_started(_anim_name):
	slot_scroll_player.play()


func _on_slot_button_down(slot: ItemSlot):
	if slot == selected_slot:
		attach_item_to_cursor(slot)


func _on_slot_button_up(slot: ItemSlot):
	scroll_to_slot(slot)


func update_slots_item_datas():
	for slot: ItemSlot in slot_grid.get_children():
		if InventoryManager.items.has(slot.slot_number):
			slot.set_item(InventoryManager.items[slot.slot_number])
		elif slot.has_item():
			slot.set_item(null)
