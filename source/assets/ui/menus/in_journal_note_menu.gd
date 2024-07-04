extends Menu

signal back_button_pressed

var note_text: String

@onready var note_text_label: Label = $cont/v_box_cont/scroll_cont/text
@onready var back_button = $cont/v_box_cont/h_box_cont/back_button
@onready var scroll_cont = $cont/v_box_cont/scroll_cont


func _enter_tree():
	if not is_node_ready():
		await ready
	
	scroll_cont.scroll_vertical = 0
	note_text_label.text = note_text


func _on_back_button_pressed():
	back_button_pressed.emit()
