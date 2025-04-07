@tool
class_name Moveable
extends Interactable

@export var move_to_offset: Vector3 = Vector3.ZERO : set = _set_move_to_offset
@export var global_signal_emit_on_move: String

# For when the player leaves the "no_interact_area" and interactable is supposed
# to still be off
var interactable_override: bool

@onready var static_body = $StaticBody
@onready var moveable_collision_blocker = $MoveableCollisionBlocker
@onready var moveable_collision_blocker_shape = $MoveableCollisionBlocker/CollisionShape
@onready var no_interact_area = $NoInteractArea
@onready var move_player = $StaticBody/MovePlayer


func _ready():
	super()
	update_move_to_collision()


func interact():
	super()
	moveable_collision_blocker.position = move_to_offset
	moveable_collision_blocker_shape.disabled = false
	moveable_collision_blocker.top_level = true
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var duration: float = move_player.stream.get_length() * (2.0 - move_player.pitch_scale)
	tween.tween_property(self, "position", move_to_offset.rotated(Vector3.UP, rotation.y), duration).as_relative()
	
	GlobalSignals.emit_signal(global_signal_emit_on_move)
	
	move_player.play()
	set_interactable(false)
	
	await tween.finished
	moveable_collision_blocker_shape.disabled = true


func _set_move_to_offset(offset: Vector3):
	move_to_offset = offset
	update_move_to_collision()


func update_move_to_collision():
	if no_interact_area:
		no_interact_area.position = move_to_offset


func _on_no_interact_area_body_entered(body):
	if body == Global.player:
		set_interactable_override(false)


func _on_no_interact_area_body_exited(body):
	if body == Global.player:
		set_interactable_override(true)


func set_interactable_override(interactable_override_: bool):
	interactable_override = interactable_override_
	for area: InteractArea in interact_areas:
		if area:
			area.set_collision_layer_value(16, interactable_override and interactable)
