extends Interactable

const LOCKED_POS_X: float = -0.557
const UNLOCKED_POS_X: float = -0.385

var locked: bool = false

# Set by parent doro script
var parent_door: Door

@onready var interact_area = $interact_area
@onready var anim_player = $anim_player
@onready var mesh = $mesh


func _ready():
	super()
	init(Type.MISC, interact_area, [mesh])
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
		parent_door.on_latch_toggle(true)
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
		parent_door.on_latch_toggle(false)
		locked = false


func set_locked(locked_: bool):
	locked = locked_
	if mesh:
		if locked:
			mesh.position.x = LOCKED_POS_X
		else:
			mesh.position.x = UNLOCKED_POS_X
