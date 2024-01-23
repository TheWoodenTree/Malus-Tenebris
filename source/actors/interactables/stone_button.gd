extends Interactable

@export var connected_node_name: String

@onready var mesh = $mesh
@onready var interact_area = $interact_area
@onready var push_player: AudioStreamPlayer3D = $push_player


func _ready():
	init(Type.MISC, interact_area)


func _process(_delta):
	if being_looked_at and interactable:
		mesh.material_overlay.set_shader_parameter("outlineOn", true)
		outline_on = true
	elif outline_on:
		mesh.material_overlay.set_shader_parameter("outlineOn", false)
		outline_on = false


func interact():
	var push_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	push_tween.tween_property(mesh, "position:z", 0.15, 0.7).as_relative()
	#set_interactable(false)
	push_player.play()
	await get_tree().create_timer(1.0).timeout
	mesh.position.z -= 0.15
	get_parent().get_node("%" + connected_node_name).interact()
