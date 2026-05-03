class_name AreYouSureMenu
extends Menu

var label_text: String
var yes_callback: Callable

@onready var are_you_sure_label: Label = $Cont/VBoxCont/AreYouSureLabel


func _enter_tree() -> void:
	if not is_node_ready():
		await ready
	
	are_you_sure_label.text = label_text


func _on_yes_button_pressed():
	yes_callback.call()


func _on_no_button_pressed():
	Global.ui.menu_manager.remove_menu()


func set_label_text(text: String):
	label_text = text


func set_yes_callback(callback: Callable):
	yes_callback = callback
