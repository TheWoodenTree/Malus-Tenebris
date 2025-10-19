@tool
class_name Chest
extends Draggable


func add_torque_to_draggable_body(offset: Vector2):
	if being_dragged_by:
		cam_rot_offset = offset
		var torque: Vector3 = Vector3.LEFT * cam_rot_offset.x * 1000.0
		draggable_body.apply_torque(torque.rotated(Vector3.UP, rotation.y))
		Global.camera_controller.set_sens_mult_to_drag_sens_mult()
		last_cam_rot_offset = offset
