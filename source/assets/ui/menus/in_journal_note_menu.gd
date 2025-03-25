extends Menu

signal back_button_pressed

var note_text: String

@onready var note_text_label: Label = $Cont/VBoxCont/ScrollCont/Text
@onready var back_button = $Cont/VBoxCont/HBoxCont/BackButton
@onready var scroll_cont = $Cont/VBoxCont/ScrollCont


func _enter_tree():
	if not is_node_ready():
		await ready
	
	scroll_cont.scroll_vertical = 0
	note_text_label.text = note_text


func _on_back_button_pressed():
	back_button_pressed.emit()
