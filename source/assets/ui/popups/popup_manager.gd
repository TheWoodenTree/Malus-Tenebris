class_name PopupManager
extends Control

signal background_changed

var current_popup: UIPopup

@onready var background: ColorRect = $Background


func display_popup(popup: UIPopup):
	if current_popup:
		remove_popup()
	
	current_popup = popup
	add_child(popup)
	set_blur_background(true)
	
	Global.ui.set_process_input(false)
	get_tree().paused = true
	Global.player.in_menu = true


func remove_popup():
	if current_popup:
		set_blur_background(false)
		remove_child(current_popup)
		current_popup = null
		Global.ui.set_process_input(true)
		get_tree().paused = false
		Global.player.in_menu = false
	else:
		push_error("Error: tried removing popup when there isn't one")


func has_popup():
	return current_popup != null


func set_blur_background(on: bool):
	if on:
		var blur_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var background_alpha := 0.75
		var background_blur := 0.9
		blur_tween.tween_property(background, "color:a", background_alpha, 0.35)
		blur_tween.parallel().tween_property(Global.retro_shader, "shader_parameter/blurAmount", background_blur, 0.35)
		blur_tween.tween_callback(background_changed.emit)
	else:
		background.color.a = 0.0
		Global.retro_shader.set_shader_parameter("blurAmount", 0.0)
		background_changed.emit()
