extends Node2D

const MOUSE_TIP_OFFSET = (Vector2.DOWN + Vector2.RIGHT) * 10.0

@onready var attached_item = $attached_item


func _process(_delta):
	position = get_viewport().get_mouse_position() + MOUSE_TIP_OFFSET
