extends Node3D

var flip = false


func _on_area_3d_body_entered(body):
	if body == Global.player:
		if flip:
			$trick_wall.rotation.y += deg_to_rad(90.0)
		else:
			$trick_wall.rotation.y -= deg_to_rad(90.0)
		flip = !flip
