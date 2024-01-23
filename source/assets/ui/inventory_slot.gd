extends MarginContainer

var index: int
var has_item: bool = false
var selected: bool = false
var on_edge: bool = false

@onready var button = $slot_button
@onready var hover_sound_player = $hover_sound_player
@onready var slot_frame = $slot_frame
@onready var item_texture_rect = $item_texture_rect

@export var item_data: ItemData


func set_item(new_item_data: ItemData):
	# If item_data has name, assume new item is being added. If not, assume
	# slot is being reset.
	if new_item_data.name:
		button.disabled = false
		has_item = true
	else:
		button.disabled = true
		has_item = false
	item_texture_rect.texture = new_item_data.texture
	item_data = new_item_data


func set_selected(is_selected):
	selected = is_selected


func set_button_disabled(disabled: bool):
	button.disabled = disabled


func set_item_visible(item_visible: bool):
	item_texture_rect.visible = item_visible


func _on_slot_button_mouse_entered():
	if not button.disabled:
		hover_sound_player.play()


func _on_slot_button_button_up():
	Global.ui.inventory_menu.scroll_to_slot(self)


func _on_slot_button_button_down():
	if selected and not Global.ui.inventory_menu.scrolling:
		Global.ui.inventory_menu.attach_item_to_cursor(item_data)
