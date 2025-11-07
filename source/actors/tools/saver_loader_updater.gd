@tool
extends Node

@export var parent_class_name: String
@export var properties: Array[String]
@export_tool_button("Update") var add_save_properties : Callable = _add_save_properties
@export_tool_button("Update") var remove_save_properties : Callable = _remove_save_properties


func _add_save_properties(node: Node = get_parent()):
	for child: Node in node.get_children():
		var script: Script = node.get_script()
		if child is SaverLoader and script and script.get_global_name() == parent_class_name:
			child = child as SaverLoader
			for property: String in properties:
				if not child.save_properties.has(property):
					child.save_properties.append(property)
		else:
			_add_save_properties(child)


func _remove_save_properties(node: Node = get_parent()):
	for child: Node in node.get_children():
		var script: Script = node.get_script()
		if child is SaverLoader and script and script.get_global_name() == parent_class_name:
			child = child as SaverLoader
			for property: String in properties:
				if child.save_properties.has(property):
					child.save_properties.erase(property)
		else:
			_add_save_properties(child)
