extends Node2D

const MOUSE_TIP_OFFSET = (Vector2.DOWN + Vector2.RIGHT) * 10.0

@onready var attached_item = $AttachedItem


func _process(_delta):
	if visible: # TODO: Make this not reset the mouse to middle of screen / prevent teleporting cursor on frame one of menu open
		position = get_viewport().get_mouse_position() + MOUSE_TIP_OFFSET
