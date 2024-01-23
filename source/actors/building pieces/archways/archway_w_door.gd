@tool
extends Archway

@export var door_interactable = false
@export var open_angle: int = 0

@onready var hinge = $door_hinge


func _ready() -> void:
	#hinge.interactable = door_interactable
	hinge.rotation.y = deg_to_rad(open_angle)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if hinge != null:
			hinge.rotation.y = deg_to_rad(open_angle)
