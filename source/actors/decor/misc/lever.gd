extends Interactable

@onready var lever_pull_player = $LeverPullPlayer
@onready var interact_area = $InteractArea
@onready var lever_hinge = $LeverHinge

signal lever_pulled(index)


func interact():
	super()
	lever_pull_player.play()
	interact_area.set_collision_layer_value(16, false)
	var pull_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	pull_tween.tween_property(lever_hinge, "rotation:z", PI/4, 1.25).from(-PI/4)
