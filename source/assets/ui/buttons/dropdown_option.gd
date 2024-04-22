@tool
class_name DropdownOption
extends HBoxContainer

var selected_icon: CompressedTexture2D = load("res://source/assets/ui/buttons/dropdown_selected.png")
var unselected_icon: CompressedTexture2D = load("res://source/assets/ui/buttons/dropdown_unselected.png")

@export var option_name: String : set = set_option_name

@onready var button = $iconless_button
@onready var select_texture = $select_texture

signal selected


func _ready():
	button.text = option_name


func select():
	select_texture.texture = selected_icon


func deselect():
	select_texture.texture = unselected_icon


func set_option_name(option_name_: String):
	option_name = option_name_
	if button:
		button.text = option_name_


func _on_iconless_button_pressed():
	emit_signal("selected", option_name)
