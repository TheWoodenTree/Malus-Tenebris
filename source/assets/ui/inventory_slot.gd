class_name ItemSlot
extends MarginContainer

var slot_number: int
var selected: bool = false
var on_edge: bool = false

@onready var button = $SlotButton
@onready var hover_sound_player = $HoverSoundPlayer
@onready var slot_frame = $SlotFrame
@onready var item_texture_rect = $ItemTextureRect
@onready var slot_number_label: Label = $HBoxContainer/SlotNumber

@export var item_data: ItemData


func _ready() -> void:
	set_slot_number(get_index() + 1)


func set_item(new_item_data: ItemData):
	item_data = new_item_data
	if new_item_data:
		button.disabled = false
		item_texture_rect.texture = new_item_data.texture
	else:
		item_texture_rect.texture = null
		button.disabled = true


func set_selected(is_selected):
	selected = is_selected


func set_button_disabled(disabled: bool):
	button.disabled = disabled


func set_item_visible(item_visible: bool):
	item_texture_rect.visible = item_visible


func set_slot_number(number: int):
	slot_number = number
	slot_number_label.text = str(number)


func has_item() -> bool:
	return item_data != null


func _on_slot_button_mouse_entered():
	if not button.disabled:
		hover_sound_player.play()


func _on_slot_button_button_up():
	Global.ui.inventory_menu.scroll_to_slot(self)


func _on_slot_button_button_down():
	if selected and not Global.ui.inventory_menu.scrolling:
		Global.ui.inventory_menu.attach_item_to_cursor(item_data)
