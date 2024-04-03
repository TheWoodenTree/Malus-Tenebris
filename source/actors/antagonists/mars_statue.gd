extends Character

@onready var skeleton = $skeleton


func _process(_delta):
	var bone_transform: Transform3D = skeleton.get_bone_global_pose_no_override(5)
	bone_transform = bone_transform.looking_at(skeleton.to_local(Global.player.cam.global_position), Vector3.UP, true)
	skeleton.set_bone_global_pose_override(5, bone_transform, 1.0, true)
