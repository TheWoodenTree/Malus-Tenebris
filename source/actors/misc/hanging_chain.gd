@tool
extends Node3D

var chain_link_res: Resource = preload("res://source/actors/misc/chain_link.tscn")

@onready var anchor_1 = $anchor_1
@onready var anchor_2 = $anchor_2
@onready var sign = $sign
@onready var chain_1 = $chain_1
@onready var chain_2 = $chain_2
@onready var joint_1 = $joint_1
@onready var joint_2 = $joint_2

@export_range(1, 10) var length: int = 1 : set = _set_length


func _ready():
	for i in range(1, chain_1.get_child_count()):
		var child = chain_1.get_child(i)
		if chain_1.get_child(i) is RigidBody3D:
			child.get_node("joint").node_a = chain_1.get_child(i - 1).get_path()
	
	for i in range(1, chain_2.get_child_count()):
		var child = chain_2.get_child(i)
		if chain_2.get_child(i) is RigidBody3D:
			child.get_node("joint").node_a = chain_2.get_child(i - 1).get_path()
	
	joint_1.node_a = chain_1.get_child(-1).get_path()
	joint_2.node_a = chain_2.get_child(-1).get_path()


func _process(_delta):
	if not Engine.is_editor_hint():
		var player_pos: Vector3 = Global.player.global_position
		anchor_1.look_at(Vector3(player_pos.x, global_position.y, player_pos.z))
	pass

func _add_link():
	var new_link1 = chain_link_res.instantiate()
	var new_link2 = chain_link_res.instantiate()
	
	var y_pos: float
	if chain_1.get_child_count() == 1:
		y_pos = 0.0
	else:
		y_pos = chain_1.get_child(-1).position.y - 1.0
	new_link1.position.y = y_pos
	new_link2.position.y = y_pos
	
	chain_1.add_child(new_link1)
	chain_2.add_child(new_link2)


func _set_length(new_length: int) -> void:
	if new_length > length:
		for i in range(0, new_length - length):
			_add_link()
	elif new_length < length and chain_1 and chain_2:
		for i in range(0, length - new_length):
			if i < chain_1.get_child_count():
				var child1 = chain_1.get_child(-1 - i)
				if child1.get_index() > 1:
					child1.queue_free()
				var child2 = chain_2.get_child(-1 - i)
				if child2.get_index() > 1:
					child1.queue_free()
					
	length = new_length
	sign.position.y = -(length + 0.5)
