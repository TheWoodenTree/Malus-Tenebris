@tool
extends Block

@export var move_to_position: Vector3 = Vector3.ZERO

@onready var move_player: AudioStreamPlayer3D = $move_player
@onready var particles = $particles


func _ready():
	mesh.size = size
	collision_box.extents = size / 2
	if not global_triplanar:
		mesh.material = load("res://source/assets/materials/tile_wall/tile_wall_local_triplanar.tres")


func interact():
	var move_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var move_anim_dur = move_player.stream.get_length() * (2 - move_player.pitch_scale)
	move_tween.tween_property(self, "position", move_to_position, move_anim_dur).as_relative()
	#for particle in particles.get_children():
	#	particle.emitting = true
	move_player.play()
	#await move_tween.finished
	#for particle in particles.get_children():
	#	particle.emitting = false
