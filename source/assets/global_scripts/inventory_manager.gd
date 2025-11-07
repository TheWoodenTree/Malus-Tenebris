extends Node

var items: Dictionary = {}
var num_slots: int = 9

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()
@onready var inventory_menu: Inventory = Global.ui.inventory_menu


func _ready() -> void:
	add_child(saver_loader)
	saver_loader.unique_id = saver_loader.get_path() as String


func add_item(item_data: ItemData):
	for slot_number: int in range(1, num_slots + 1):
		if not items.has(slot_number):
			items[slot_number] = item_data
			break


func remove_item(item_data: ItemData):
	var slot_index: int = items.find_key(item_data)
	items.erase(slot_index)


func get_save_properties():
	return ["items"] as Array[String]
