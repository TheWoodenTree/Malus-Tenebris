class_name ItemSlot
extends MarginContainer

var hotkey_symbol: String :
	set(value):
		hotkey_symbol = value
		hotkey.text = value

var on_edge: bool = false

@onready var button: Button = $SlotButton
@onready var hover_sound_player = $HoverSoundPlayer
@onready var slot_frame = $SlotFrame
@onready var item_texture_rect = $ItemTextureRect
@onready var hotkey: Label = $HBoxContainer/Hotkey

@onready var slot_number: int = get_index() + 1

@export var item_data: ItemData
@export var display_slot_number: bool = true


func set_item(new_item_data: ItemData):
	item_data = new_item_data
	if new_item_data:
		button.disabled = false
		item_texture_rect.texture = new_item_data.texture
	else:
		item_texture_rect.texture = null
		button.disabled = true


func set_button_disabled(disabled: bool):
	button.disabled = disabled


func set_item_visible(item_visible: bool):
	item_texture_rect.visible = item_visible


func has_item() -> bool:
	return item_data != null


func _on_slot_button_mouse_entered():
	if not button.disabled:
		hover_sound_player.play()
