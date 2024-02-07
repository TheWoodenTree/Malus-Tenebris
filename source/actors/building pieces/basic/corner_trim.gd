@tool
extends Node3D

@export var length1: float = 1.0 : set = _set_length1
@export var length2: float = 1.0 : set = _set_length2
@export_enum("Concave", "Convex") var type: String = "Concave" : set = _set_type

@onready var node = $node
@onready var mesh1 = $node/mesh1
@onready var mesh2 = $node/mesh2
@onready var mesh3 = $node/mesh3
@onready var collision_shape1 = $node/body/collision_shape1
@onready var collision_shape2 = $node/body/collision_shape2
@onready var collision_shape3 = $node/body/collision_shape3


func _ready():
	if type == "Concave":
		node.position.x = 0.0
		node.position.z = 0.0
	elif type == "Convex":
		node.position.x = 0.35
		node.position.z = -0.35
	update_trim1()
	update_trim2()


func update_trim1():
	var offset: float = 0.0
	if type == "Convex":
		offset = 0.35
		
	if collision_shape1:
		collision_shape1.shape.size.z = length1 - offset
		collision_shape1.position.z = (-length1 + offset) * 0.5
	if mesh1:
		mesh1.mesh.size.z = length1 - offset
		mesh1.position.z = (-length1 + offset) * 0.5


func update_trim2():
	var offset: float = 0.0
	if type == "Convex":
		offset = 0.35
		
	if collision_shape2:
		collision_shape2.shape.size.x = length2 - offset
		collision_shape2.position.x = (length2 - offset) * 0.5
	if mesh2:
		mesh2.mesh.size.x = length2 - offset
		mesh2.position.x = (length2 - offset) * 0.5


func _set_length1(length):
	length1 = length
	update_trim1()


func _set_length2(length):
	length2 = length
	update_trim2()


func _set_type(type_):
	type = type_
	if node:
		if type == "Concave":
			node.position.x = 0.0
			node.position.z = 0.0
		elif type == "Convex":
			node.position.x = 0.35
			node.position.z = -0.35
		update_trim1()
		update_trim2()
