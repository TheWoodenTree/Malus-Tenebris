@tool
extends Area3D

@export var signal_name: String
@export var trigger_once: bool = true
@export var collision_shape_size := Vector3.ONE : set = _set_collision_shape_size

var triggered: bool = false

@onready var collision_shape: CollisionShape3D = $CollisionShape


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(emit_global_signal)
	
	collision_shape.shape.size = collision_shape_size


func emit_global_signal(body):
	if body == Global.player:
		if not triggered or not trigger_once:
			GlobalSignals.emit_signal(signal_name)
			triggered = true


func _set_collision_shape_size(size: Vector3):
	collision_shape_size = size
	if collision_shape:
		collision_shape.shape.size = collision_shape_size
