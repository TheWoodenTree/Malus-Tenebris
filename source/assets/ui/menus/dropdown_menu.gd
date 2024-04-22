@tool
extends Control

@export var option_names: Array[String] = [] : set = set_option_names

var option_res = preload("res://source/assets/ui/buttons/dropdown_option.tscn")

var option_list: Array[DropdownOption]

@onready var v_box_cont = $panel_cont/v_box_cont


func _ready():
	update_options()


func set_option_names(option_names_):
	option_names = option_names_
	option_list.clear()
	if v_box_cont:
		update_options()


func update_options():
	option_list.clear()
	for option in v_box_cont.get_children():
		option.queue_free()
	for option_name in option_names:
		var new_option: DropdownOption = option_res.instantiate()
		new_option.option_name = option_name
		new_option.selected.connect(_option_selected)
		option_list.append(new_option)
		v_box_cont.add_child(new_option)


func _option_selected(option_name: String):
	for option in option_list:
		if option.option_name == option_name:
			option.select()
		else:
			option.deselect()
