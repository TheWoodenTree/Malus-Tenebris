extends RayCast3D

var collider_last_frame: CollisionObject3D = null


func _process(_delta: float) -> void:
	var collider = get_collider()
	# Don't collide with Area3Ds that are in the world layer because those are for
	# adjusting reverb based on room because for some reason they have to have collision layer
	# bit 0 set to enabled to work
	if collider != null and collider is Area3D and collider.get_collision_layer_value(1) and collider.name != "collision_blocker":
		add_exception(collider)

	if collider != collider_last_frame:
		if collider_last_frame is InteractArea: # Untarget last targeted object
			collider_last_frame.interact_ray_stopped_colliding.emit()
			#Global.ui.interact_icon_off()
		if collider is InteractArea: # Target new object
			collider.interact_ray_collided.emit()
			#Global.ui.interact_icon_on()
		
	collider_last_frame = collider
