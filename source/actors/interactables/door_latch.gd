extends Interactable

const LOCKED_POS_X: float = -0.557
const UNLOCKED_POS_X: float = -0.385

var locked: bool = false

# Set by parent doro script
var parent_door: Door

@onready var anim_player = $anim_player
@onready var mesh = meshes[0]


func _ready():
	super()
	if locked:
		mesh.position.x = LOCKED_POS_X
	else:
		mesh.position.x = UNLOCKED_POS_X


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
