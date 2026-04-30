extends Node

const PROTECTED_HOTKEY_ACTIONS = ["journal"]

const HOTKEY_SYMBOL_MAP = {
	"inventory_hotkey_1": "1",
	"inventory_hotkey_2": "2",
	"inventory_hotkey_3": "3",
	"inventory_hotkey_4": "4",
}

var items: Dictionary = {}
var num_slots: int = 9

var hotkeys: Dictionary[String, ItemRegistry.ID] = {
	"journal": ItemRegistry.ID.JOURNAL
}

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()


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


func get_item_by_id(id: ItemRegistry.ID):
	var idx: int = items.values().find_custom(func(item_data: ItemData): return item_data.id == id)
	return items.values()[idx] if idx != -1 else null


func add_hotkey(hotkey: String, item_id: ItemRegistry.ID):
	var to_erase: Array[String] = []
	for action: String in hotkeys.keys():
		if hotkeys[action] == item_id and action not in PROTECTED_HOTKEY_ACTIONS:
			to_erase.append(action)
	
	for action in to_erase:
		hotkeys.erase(action)
	
	hotkeys[hotkey] = item_id


func get_hotkey_symbol_from_id(item_id: ItemRegistry.ID) -> String:
	for action: String in hotkeys:
		if hotkeys[action] == item_id and action not in PROTECTED_HOTKEY_ACTIONS:
			return HOTKEY_SYMBOL_MAP.get(action, "")
	return ""


func get_save_properties():
	return [
		"items",
		"hotkeys",
	] as Array[String]
