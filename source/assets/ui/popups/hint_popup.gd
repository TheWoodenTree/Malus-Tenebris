class_name HintPopup
extends UIPopup

var text: String

@onready var hint_text_label: Label = $VBoxContainer/HintTextLabel


func _enter_tree() -> void:
	if not is_node_ready():
		await ready
	
	hint_text_label.text = text


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		Global.ui.popup_manager.remove_popup()
