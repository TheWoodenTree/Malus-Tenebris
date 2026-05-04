class_name HintPopup
extends UIPopup

var text: String

@onready var hint_text_label: Label = $MarginContainer/VBoxContainer/PanelContainer/HintTextLabel


func _enter_tree() -> void:
	if not is_node_ready():
		await ready
	
	hint_text_label.text = text


func _input(event: InputEvent) -> void:
	if (event is InputEventKey and not event.is_echo()) or event is InputEventJoypadButton:
		if event.is_pressed():
			Global.ui.popup_manager.remove_popup()
