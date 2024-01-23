extends Area3D

var player_entered_area: bool = false

@onready var sound_player = $sound_player


func _on_body_entered(body):
	if body == Global.player and not player_entered_area:
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_method(set_chromatic_abberation_offset, 0.0, 7.5, 4.0)
		tween.parallel().tween_method(set_vignette_softness, 2.0, 0.8, 4.0)
		tween.parallel().tween_property(Global.player, "speed_multiplier", 0.5, 1.0)
		tween.parallel().tween_property(Global.player.cam, "sensitivity_multiplier", 0.25, 1.0)
		tween.parallel().tween_property(Global.player.cam, "bob_frequency_multiplier", 0.5, 1.0)
		tween.parallel().tween_property(Global.main, "light_energy_multiplier", 0.25, 4.0)
		sound_player.play()
		player_entered_area = true
		
		await get_tree().create_timer(8.0, false).timeout
		var tween2 = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween2.tween_method(set_chromatic_abberation_offset, 7.5, 0.0, 4.0)
		tween2.parallel().tween_method(set_vignette_softness, 0.8, 2.0, 4.0)
		tween2.parallel().tween_property(Global.player, "speed_multiplier", 1.0, 2.5)
		tween2.parallel().tween_property(Global.player.cam, "sensitivity_multiplier", 1.0, 2.5)
		tween2.parallel().tween_property(Global.player.cam, "bob_frequency_multiplier", 1.0, 2.5)
		tween2.parallel().tween_property(Global.main, "light_energy_multiplier", 1.0, 4.0)


func set_chromatic_abberation_offset(offset: float):
	Global.chromatic_abberation_shader.set_shader_parameter("offset", offset)


func set_vignette_softness(softness: float):
	Global.vignette_shader.set_shader_parameter("softness", softness)
