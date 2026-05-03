class_name BlockingHintPopup
extends Control

@onready var background: ColorRect = $Background
@onready var hint_text_label: Label = $VBoxContainer/HintTextLabel


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventJoypadButton:
		Global.ui.remove_blocking_hint_popup()


func set_blur_background(on: bool):
	var blur_tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var background_alpha: float
	var background_blur: float
	if on:
		background_alpha = 0.75
		background_blur = 0.9
	else:
		background_alpha = 0.0
		background_blur = 0.0
	blur_tween.tween_property(background, "color:a", background_alpha, Global.UI.BLUR_TIME)
	blur_tween.parallel().tween_property(Global.retro_shader, "shader_parameter/blurAmount", background_blur, Global.UI.BLUR_TIME)
