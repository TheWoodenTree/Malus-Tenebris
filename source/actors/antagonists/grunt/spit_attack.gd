class_name SpitAttack
extends Attack

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spit_attack_area: Area3D = $SpitAttackArea
@onready var particles_and_sound: Node3D = $ParticlesAndSound


func _ready() -> void:
	spit_attack_area.body_entered.connect(_on_spit_attack_area_body_entered)


func _on_spit_attack_area_body_entered(_body: PhysicsBody3D):
	Global.player.hurt(self)


func play_anim():
	animation_player.play("SpitAttack")


func set_particles_and_sound_global_position(pos: Vector3):
	particles_and_sound.global_position = pos
