class_name HintPopup
extends UIPopup

var text: String
var timer: Timer

@onready var hint_text_label: Label = $MarginContainer/VBoxContainer/PanelContainer/HintTextLabel
@onready var press_any_button_label: Label = $MarginContainer/PressAnyButtonLabel


func _enter_tree() -> void:
	if not is_node_ready():
		await ready
	
	hint_text_label.text = text
	
	if not timer.is_inside_tree():
		await timer.tree_entered
	
	timer.start()


func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.5
	timer.one_shot = true
	
	timer.timeout.connect(func(): press_any_button_label.visible = true)


func _input(event: InputEvent) -> void:
	if (event is InputEventKey and not event.is_echo()) or event is InputEventJoypadButton:
		if event.is_pressed() and timer.is_stopped():
			Global.ui.popup_manager.remove_popup()
			press_any_button_label.visible = false
