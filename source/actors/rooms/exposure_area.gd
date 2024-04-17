extends Area3D

var player_entered_area: bool = false

@onready var sound_player = $sound_player


#TODO: Fix door swinging wildly when mouse sensitivity is adjusted
func _on_body_entered(body):
	if body == Global.player and not player_entered_area:
		AfflictionEffectController.set_to_beyond_max_effect(4.0)
		sound_player.play()
		player_entered_area = true
		
		await get_tree().create_timer(10.0, false).timeout
		AfflictionEffectController.set_to_max_effect(4.0)


func set_chromatic_abberation_offset(offset: float):
	Global.chromatic_abberation_shader.set_shader_parameter("offset", offset)


func set_vignette_softness(softness: float):
	Global.vignette_shader.set_shader_parameter("softness", softness)
