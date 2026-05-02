@tool
extends Area3D

@export var events: Array[Event]
@export var collision_shape_size := Vector3.ONE : set = _set_collision_shape_size

@onready var collision_shape: CollisionShape3D = $CollisionShape


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
	
	collision_shape.shape.size = collision_shape_size


func _set_collision_shape_size(size: Vector3):
	collision_shape_size = size
	if collision_shape:
		collision_shape.shape.size = collision_shape_size


func _on_body_entered(_body: PhysicsBody3D):
	for event: Event in events:
		await event.execute()
