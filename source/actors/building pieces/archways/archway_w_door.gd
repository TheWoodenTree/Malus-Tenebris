@tool
extends Archway

@export var door_interactable = false
@export var initial_rotation: int = 0

@onready var hinge = $DoorHinge


func _ready() -> void:
	#hinge.interactable = door_interactable
	hinge.rotation.y = deg_to_rad(initial_rotation)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if hinge != null:
			hinge.rotation.y = deg_to_rad(initial_rotation)
