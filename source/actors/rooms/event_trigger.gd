extends Area3D


func _on_body_entered(body):
	if body == Global.monster:
		AfflictionEffectController.override_effect_scale = true
		var tween1 = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween1.parallel().tween_property(Global.vignette_shader, "shader_parameter/multiplier", 0.0, 2.0)
		tween1.parallel().tween_property(Global.vignette_shader, "shader_parameter/softness", 0.0, 2.0)
		tween1.tween_callback(func(): Global.ui.display_death_screen(); Global.monster.global_position = Vector3(0.0, 200.0, 0.0))
		var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween2.tween_property(Global.zoom_shader, "shader_parameter/intensity", 30.0, 1.0)
