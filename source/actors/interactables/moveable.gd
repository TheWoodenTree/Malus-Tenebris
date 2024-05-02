@tool
class_name Moveable
extends Interactable

@export var move_to_offset: Vector3 = Vector3.ZERO : set = _set_move_to_offset

# For when the player leaves the "no_interact_area" and interactable is supposed
# to still be off
var _interactable: bool = interactable

@onready var interact_area = $interact_area
@onready var static_body = $static_body
@onready var moveable_collision_blocker = $moveable_collision_blocker
@onready var moveable_collision_blocker_shape = $moveable_collision_blocker/collision_shape
@onready var no_interact_area = $no_interact_area
@onready var move_player = $static_body/move_player
@onready var mesh = $mesh


func _ready():
	super()
	if not Engine.is_editor_hint():
		init(Type.MISC, interact_area, [mesh])
	update_move_to_collision()


func _process(_delta):
	if not Engine.is_editor_hint():
		if interactable and being_looked_at:
			mesh.material_overlay.set_shader_parameter("outlineOn", true)
			outline_on = true
		elif outline_on:
			mesh.material_overlay.set_shader_parameter("outlineOn", false)
			outline_on = false


func interact():
	moveable_collision_blocker.position = move_to_offset.rotated(Vector3.UP, rotation.y)
	moveable_collision_blocker_shape.disabled = false
	moveable_collision_blocker.top_level = true
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var duration: float = move_player.stream.get_length() * (2.0 - move_player.pitch_scale)
	tween.tween_property(self, "position", -move_to_offset, duration).as_relative()
	move_player.play()
	_interactable = false
	set_interactable(false)


func _set_move_to_offset(offset: Vector3):
	move_to_offset = offset
	update_move_to_collision()


func update_move_to_collision():
	if no_interact_area:
		no_interact_area.position = move_to_offset.rotated(Vector3.UP, rotation.y)


func _on_no_interact_area_body_entered(body):
	if body == Global.player:
		set_interactable(false)


func _on_no_interact_area_body_exited(body):
	if body == Global.player and _interactable:
		set_interactable(true)
