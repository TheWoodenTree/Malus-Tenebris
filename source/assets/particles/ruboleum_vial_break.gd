extends Node3D

# Set by thrown object
var relative_up_direction: Vector3 = Vector3.ZERO

@onready var particles = $Particles
@onready var particles2 = $Particles2
@onready var light = $Light
@onready var anim_player = $AnimPlayer


#TODO: Fix particle emission direction based on collision normal
func play():
	particles.process_material.direction = relative_up_direction
	particles2.process_material.direction = relative_up_direction
	light.position = relative_up_direction * 0.2
	anim_player.play("break")
