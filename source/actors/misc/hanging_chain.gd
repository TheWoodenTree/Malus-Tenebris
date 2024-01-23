@tool
extends Node3D

var chain_link_res: Resource = preload("res://source/actors/misc/chain_link.tscn")

@onready var anchor = $anchor

@export_range(1, 10) var length: int = 1 : set = _set_length


func _ready():
	for i in range(0, get_child_count()):
		var child = get_child(i)
		if get_child(i) is RigidBody3D:
			child.get_node("joint").node_a = get_child(i - 1).get_path()


func _process(_delta):
	if not Engine.is_editor_hint():
		var player_pos: Vector3 = Global.player.global_position
		anchor.look_at(Vector3(player_pos.x, global_position.y, player_pos.z))
	pass

func _add_link():
	var new_link = chain_link_res.instantiate()
	
	var y_pos: float
	if get_child_count() == 1:
		y_pos = 0.0
	else:
		y_pos = get_child(-1).position.y - 1.0
	new_link.position.y = y_pos
	
	add_child(new_link)


func _set_length(new_length: int) -> void:
	if new_length > length:
		for i in range(0, new_length - length):
			_add_link()
	elif new_length < length:
		for i in range(0, length - new_length):
			if i < get_child_count():
				var child = get_child(-1 - i)
				if child.get_index() > 1:
					child.queue_free()
	length = new_length
