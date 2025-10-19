class_name SpitAttack
extends Attack

var particles_emitted := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spit_attack_area: Area3D = $SpitAttackArea
@onready var particles_and_sound: Node3D = $ParticlesAndSound
@onready var spit_particles: GPUParticles3D = $ParticlesAndSound/SpitParticles
@onready var spit_sound_player: AudioStreamPlayer3D = $ParticlesAndSound/SpitSoundPlayer


func _ready() -> void:
	spit_attack_area.body_entered.connect(_on_spit_attack_area_body_entered)
	animation_player.animation_finished.connect(func(_animation): particles_emitted = false)


func _on_spit_attack_area_body_entered(_body: PhysicsBody3D):
	Global.player.hurt(self)


func play_sound():
	spit_sound_player.play()


func play_anim():
	var direction: Vector3 = particles_and_sound.position.direction_to(to_local(Global.camera_controller.global_position))
	spit_particles.process_material.direction.y = direction.y
	spit_particles.process_material.direction.z = -abs(direction.z)
	animation_player.play("SpitAttack") # TODO: Make hitbox affected by direction of particles
	particles_emitted = true


func set_particles_and_sound_global_position(pos: Vector3):
	particles_and_sound.global_position = pos
