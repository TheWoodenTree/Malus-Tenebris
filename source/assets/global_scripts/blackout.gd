extends Node

var color_rect: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color_rect = ColorRect.new()
	color_rect.material = load("res://source/assets/shaders/blackout_shader_mat.tres")
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.z_index = 1000
	add_child(color_rect)
