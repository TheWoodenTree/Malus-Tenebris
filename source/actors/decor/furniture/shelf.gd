@tool
extends Interactable

@export var move_to_pos = Vector3.ZERO : set = _set_move_to_pos

@onready var interact_mat = $mesh.material_overlay
@onready var scrape_player = $scrape_player
@onready var interact_area = $interact_area
@onready var blocking_body = $blocking_body
@onready var move_to_collision = $blocking_body/move_to_collision


func _ready() -> void:
	if Engine.is_editor_hint():
		blocking_body.rotation = rotation
	else:
		if has_node("interact_area"):
			interact_area = $interact_area
		init(Type.MOVEABLE, interact_area)
		var _err = get_node("%note").was_read.connect(set_interactable.bind(true))
		if interactable:
			interact_area.monitoring = true
			interact_area.monitorable = true
		
		interact_mat.set_shader_parameter("outlineOn", false)


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		if interactable:
			# Enable interaction outline if being looked at
			interact_mat.set_shader_parameter("outlineOn", being_looked_at)


func interact():
	if interactable:
		var pos_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		move_to_collision.disabled = false
		pos_tween.tween_property(self, "position", move_to_pos, 1.6).as_relative()
		pos_tween.tween_callback(set.bind("move_to_collision:disabled", true))
		scrape_player.play()
		set_interactable(false)
		interact_mat.set_shader_parameter("outlineOn", false)
		interact_area.queue_free()


func _set_move_to_pos(pos: Vector3):
	move_to_pos = pos
	#move_to_collision.position = pos.rotated(Vector3.UP, rotation.y)
