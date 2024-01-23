extends Path3D

var can_trigger = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_body_entered(body):
	if body == Global.player and can_trigger:
		var tween = get_tree().create_tween()
		tween.tween_property($PathFollow3D, "progress_ratio", 1.0, 5.0)
		$PathFollow3D/obunga/AudioStreamPlayer3D.play()
		can_trigger = false
