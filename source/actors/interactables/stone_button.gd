extends Interactable

@export var connected_node_name: String

@onready var push_player: AudioStreamPlayer3D = $push_player
@onready var mesh = meshes[0]


func interact():
	super()
	var push_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	push_tween.tween_property(mesh, "position:z", 0.15, 0.7).as_relative()
	#set_interactable(false)
	push_player.play()
	await get_tree().create_timer(1.0).timeout
	mesh.position.z -= 0.15
	get_parent().get_node("%" + connected_node_name).interact()
