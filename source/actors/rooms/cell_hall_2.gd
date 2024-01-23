extends Node3D


func _on_banging_trigger_area_body_entered(body):
	if body == Global.player:
		#$lower_entrance/door.open(false)
		pass
