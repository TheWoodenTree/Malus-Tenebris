@tool
class_name SaverLoader
extends Node

const META_PREFIX_IS_RESOURCE_PATH = "_is_resource_path:"
const META_KEY_RESOURCE_PATH = &"_resource_path"
const META_KEY_SCRIPT_PATH = &"_script_path"

static var unique_id_charset := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=;:,."

@export var unique_id: StringName
@export_tool_button("Generate Unique ID") var generate_unique_id: Callable = _generate_unique_id
@export var save_properties: Array[String]
@export var is_dynamically_spawned: bool = false

var new_save_data: Dictionary[StringName, Variant]

@onready var parent: Node = get_parent()


func _ready() -> void:
	SaveManager.register_saver_loader(self)
	if not unique_id:
		push_error(str(get_parent().get_path()) + " does not have a unique SaverLoader ID.")


func save_data() -> Dictionary[StringName, Variant]:
	new_save_data = {}
	
	for property_path: StringName in save_properties:
		var value: Variant = parent.get(property_path)
		if value == null:
			push_error(str(get_parent().get_path()) + " Has no property to save: " + property_path )
			continue
		new_save_data[property_path] = serialize_data(value)
		
	return new_save_data


func load_data(data: Dictionary[StringName, Variant]):
	for property_path: StringName in data.keys():
		if parent.get(property_path) == null:
			push_error(str(get_parent().get_path()) + " Has no property to load: " + property_path )
			continue
		
		var deserialized = deserialize_data(data[property_path])
		
		var current_value = parent.get(property_path)
		
		if current_value is Dictionary and deserialized is Dictionary:
			current_value.clear()
			for k in deserialized.keys():
				current_value[k] = deserialized[k]
		
		elif current_value is Array and deserialized is Array:
			current_value.clear()
			for item in deserialized:
				current_value.append(item)
		else:
			parent.set(property_path, deserialized)


func serialize_data(value: Variant) -> Variant:
	if value == null:
		return null
	
	elif value is Resource:
		if value.resource_path != "":
			return META_PREFIX_IS_RESOURCE_PATH + value.resource_path
		else:
			var script: Script = value.get_script()
			var dict: Dictionary[StringName, Variant] = {}
			if script:
				dict[META_KEY_SCRIPT_PATH] = script.resource_path
			else:
				dict[META_KEY_RESOURCE_PATH] = value.get_class()
			for property: Variant in value.get_property_list():
				var prop_name: StringName = property.name
				var prop_value: Variant = value.get(prop_name)
				if (ClassDB.is_parent_class(property.class_name, "Node")): # Do not serialize nodes
					continue
				dict[prop_name] = serialize_data(prop_value)
			return dict
	
	elif value is Array:
		var array: Array[Variant] = []
		for v: Variant in value:
			array.append(serialize_data(v))
		return array
	
	elif value is Dictionary:
		var dict: Dictionary[Variant, Variant] = {}
		for k: Variant in value.keys():
			dict[k] = serialize_data(value[k])
		return dict
	
	else:
		return value


func deserialize_data(value: Variant) -> Variant:
	if value is String:
		if value.contains(META_PREFIX_IS_RESOURCE_PATH):
			value = value.substr(value.find(":") + 1)
			if ResourceLoader.exists(value):
				return load(value)
			else:
				push_error(str(get_parent().get_path()) + " Resource path does not exist to load: " + value)
				return null
		else:
			return value
	
	elif value is Array:
		var array: Array[Variant] = []
		for v: Variant in value:
			array.append(deserialize_data(v))
		return array
	
	elif value is Dictionary:
		var is_built_in_resource: bool = META_KEY_RESOURCE_PATH in value
		var is_custom_resource: bool = META_KEY_SCRIPT_PATH in value
		if is_built_in_resource || is_custom_resource:
			var res: Resource
			if is_built_in_resource:
				var cls_name: String = value[META_KEY_RESOURCE_PATH]
				if ClassDB.class_exists(cls_name):
					res = ClassDB.instantiate(cls_name)
				else:
					push_error(str(parent.get_path()) + " Cannot find class: " + cls_name)
			else:
				var script_path: String = value[META_KEY_SCRIPT_PATH]
				var script: Script = load(script_path)
				if script:
					res = script.new()
				else:
					push_error(str(parent.get_path()) + " Cannot load script as resource: " + script_path)
			for k: Variant in value.keys():
				if k == META_KEY_RESOURCE_PATH or k == META_KEY_SCRIPT_PATH:
					continue
				res.set(k, deserialize_data(value[k]))
			return res
		else:
			var dict: Dictionary[Variant, Variant] = {}
			for k: Variant in value.keys():
				dict[k] = deserialize_data(value[k])
			return dict
	
	else:
		return value


func _generate_unique_id():
	var id := ""
	for i in range(16):
		id += unique_id_charset[randi() % unique_id_charset.length()]
	unique_id = id as StringName
