class_name Cursor
extends Node2D

const MOUSE_TIP_OFFSET = (Vector2.DOWN + Vector2.RIGHT) * 10.0

var attached_item_data: ItemData :
	set(value):
		attached_item_data = value
		attached_item_sprite.texture = value.texture if value != null else null

var attached_item_source: ItemSlot

@onready var attached_item_sprite = $AttachedItemSprite


func _ready() -> void:
	Global.cursor = self


func _process(_delta):
	if visible: # TODO: Make this not reset the mouse to middle of screen / prevent teleporting cursor on frame one of menu open
		position = get_viewport().get_mouse_position() + MOUSE_TIP_OFFSET


func attach_item(item_data: ItemData, source: ItemSlot):
	attached_item_data = item_data
	attached_item_source = source


func detatch_item():
	attached_item_data = null
	attached_item_source = null


func has_attached_item():
	return attached_item_data != null
