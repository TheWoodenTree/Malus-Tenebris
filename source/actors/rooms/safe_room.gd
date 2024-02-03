extends Node3D

@onready var music_player = $music_player


func _on_safe_room_area_body_entered(body):
	if body == Global.player:
		var tween = get_tree().create_tween()
		tween.tween_property(Global.main.drip_player, "volume_db", -50, 3.0,)
		tween.parallel().tween_property(Global.main.drone_player, "volume_db", -30, 3.0)
		#tween.parallel().tween_property(music_player, "volume_db", -10, 3.0).from(-50).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		#music_player.play()


func _on_safe_room_area_body_exited(body):
	if body == Global.player:
		var tween = get_tree().create_tween()
		tween.tween_property(Global.main.drip_player, "volume_db", -16, 3.0,)
		tween.parallel().tween_property(Global.main.drone_player, "volume_db", -6, 3.0)
		#tween.parallel().tween_property(music_player, "volume_db", -35, 3.0).from(-10).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		#tween.tween_callback(music_player.set.bind("playing", false))
