extends Node

const SAVER_LOADER_UNIQUE_ID = "hRJ07t(&EG5hpu$3"

var items: Dictionary = {}
var num_slots: int = 9

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()
@onready var inventory_menu: Inventory = Global.ui.inventory_menu


func _ready() -> void:
	saver_loader.unique_id = SAVER_LOADER_UNIQUE_ID
	saver_loader.save_properties = ["items"]
	add_child(saver_loader)


func add_item(item_data: ItemData):
	for slot_number: int in range(1, num_slots + 1):
		if not items.has(slot_number):
			items[slot_number] = item_data
			break


func remove_item(item_data: ItemData):
	var slot_index: int = items.find_key(item_data)
	items.erase(slot_index)
