@tool
class_name DropdownButton
extends IconlessButton

@export var dropdown_option_names: Array[String] = [] : set = _set_dropdown_option_names

@onready var dropdown_menu = $dropdown_menu
@onready var dropdown_menu_cont = $dropdown_menu/panel_cont/v_box_cont

var dropdown_option_res = preload("res://source/assets/ui/buttons/dropdown_option.tscn")
var dropdown_option_list: Array[DropdownOption]
var selected_option: String


func _ready():
	dropdown_menu.set_option_names(dropdown_option_names)
	dropdown_menu.visible = false
	dropdown_menu.mouse_filter = MOUSE_FILTER_IGNORE
	for option in dropdown_menu.option_list:
		option.selected.connect(_option_selected)


func _on_pressed():
	dropdown_menu.visible = not dropdown_menu.visible
	dropdown_menu.mouse_filter = MOUSE_FILTER_STOP if dropdown_menu.visible else MOUSE_FILTER_IGNORE


func _option_selected(option_name: String):
	if selected_option != option_name:
		selected_option = option_name
		text = selected_option
		dropdown_menu.visible = false
		dropdown_menu.mouse_filter = MOUSE_FILTER_IGNORE


func _set_dropdown_option_names(dropdown_option_names_):
	dropdown_option_names = dropdown_option_names_
	if dropdown_menu:
		dropdown_menu.set_option_names(dropdown_option_names_)
