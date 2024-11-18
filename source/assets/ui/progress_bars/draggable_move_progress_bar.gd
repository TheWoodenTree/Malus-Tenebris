extends Control

enum {LEFT, RIGHT}

const MAX_ARROW_PIXEL_OFFSET: float = 112.0

var direction: int = LEFT

var current_draggable: Object

# "Drag" could refer to angle or length
var draggable_max_drag: float = 85.0
var draggable_last_drag: float

@onready var bar = $cont/bar
@onready var arrow = $cont/bar/arrow


func _ready():
	#Global.player.draggable_interacted.connect(connect_draggable)
	pass


func connect_draggable(draggable: Object):#, max_drag: float):
	if current_draggable:
		current_draggable.moved.disconnect(update_progress)
	current_draggable = draggable
	current_draggable.moved.connect(update_progress)
	#draggable_max_drag = max_drag


func update_progress(drag_amount: float, player_in_front: bool):
	var drag_difference_sign: int = sign(drag_amount - draggable_last_drag)
	if player_in_front:
		arrow.flip_h = drag_difference_sign == 1
		arrow.position.x = lerp(MAX_ARROW_PIXEL_OFFSET, 0.0, drag_amount / draggable_max_drag)
	else:
		arrow.flip_h = drag_difference_sign == -1
		arrow.position.x = lerp(0.0, MAX_ARROW_PIXEL_OFFSET, drag_amount / draggable_max_drag)
	draggable_last_drag = drag_amount
