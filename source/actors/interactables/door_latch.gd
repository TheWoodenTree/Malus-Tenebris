@tool
extends Interactable

const LOCKED_POS_X: float = -0.557
const UNLOCKED_POS_X: float = -0.385

var locked: bool = false

# Set by doorway script
var parent_door: Node3D

@onready var mesh = $mesh
@onready var interact_area = $interact_area
@onready var anim_player = $anim_player

signal toggled


func _ready():
	init(Type.MISC, interact_area)
	if locked:
		mesh.position.x = LOCKED_POS_X
	else:
		mesh.position.x = UNLOCKED_POS_X


func _process(_delta):
	if not Engine.is_editor_hint():
		if being_looked_at:
			mesh.material_overlay.set_shader_parameter("outlineOn", true)
			outline_on = true
		elif outline_on:
			mesh.material_overlay.set_shader_parameter("outlineOn", false)
			outline_on = false


func interact():
	if not locked:
		emit_signal("toggled", true)
		set_interactable(false)
		anim_player.play("lock")
		await anim_player.animation_finished
		set_interactable(true)
		locked = true
	else:
		set_interactable(false)
		anim_player.play("unlock")
		await anim_player.animation_finished
		set_interactable(true)
		emit_signal("toggled", false)
		locked = false


func set_locked(locked_: bool):
	locked = locked_
	if mesh:
		if locked:
			mesh.position.x = LOCKED_POS_X
		else:
			mesh.position.x = UNLOCKED_POS_X


func on_door_close_toggle(closed: bool):
	set_interactable(closed)
