extends Interactable

const MIN_IMPACT_VEL = 1
const MOMENT_OF_INERTIA = 0.21333
const MAX_KE = 50
const MIN_PITCH = 0.8
const MAX_PITCH = 1
const MIN_HIT_VOL = -5
const MAX_HIT_VOL = 5

var flicker_intensity = 1.2

var cam_rot_last_frame := Vector3.ZERO

var hit_sound_timer = Timer.new()

var is_lit = false
var held_by_player = false
var looked_at_last_frame = false

@export var default_range: float = 12.0
@export var default_energy: float = 1.25

@onready var material = $Mesh.material_overlay
@onready var particles = $FireParticles
@onready var light = $FireParticles/Light
@onready var torch_light_player = $TorchLightPlayer
@onready var pickup_player = $PickupPlayer
@onready var burning_player = $BurningPlayer
@onready var swoosh_player: AudioStreamPlayer3D = $SwooshPlayer
@onready var lit_particles = $LitFireParticles
@onready var movement_particle_attractor: GPUParticlesAttractorSphere3D = $MovementParticleAttractor
@onready var rotation_particle_attractor: GPUParticlesAttractorSphere3D = $RotationParticleAttractor
@onready var interact_area = $InteractArea
@onready var mesh = meshes[0]
@onready var swoosh_timer = Timer.new()


func _ready() -> void:
	super()
	
	Global.torch = self
	# All fire burning sound players are synced off the playback position of the player torch
	# so it must be playing at all times rather than be paused
	burning_player.volume_db = -80.0
	
	light.omni_range = default_range
	light.light_energy = default_energy
	particles.emitting = false
	light.visible = false
	hit_sound_timer.wait_time = 0.2
	hit_sound_timer.one_shot = true
	swoosh_timer.one_shot = true
	swoosh_timer.wait_time = 0.2
	add_child(swoosh_timer)


func _process(_delta: float) -> void:
	calculate_fire_up_dir()
	update_movement_particle_attractor_transform()
	update_rotation_particle_attractor_transform()
	
	if held_by_player:
		#global_position = Global.player.torch_pos.global_position
		#rotation = Global.player.torch_pos.rotation
		global_transform = Global.player.torch_pos.global_transform


func interact():
	super()
	held_by_player = true
	Global.player.torch = self
	Global.player.has_torch = true
	get_tree().call_group("fire_sources", "update_interactable")
	
	pickup_player.play()
	particles.local_coords = true
	mesh.layers = 2
	light.visible = false
	
	highlight_light.visible = false
	
	if not Global.player.debug_has_torch:
		Global.ui.hint_popup("Find a way to light the torch", 5.0)


func calculate_fire_up_dir():
	particles.process_material.direction = Vector3.UP.rotated(Vector3.LEFT, global_rotation.x)


func update_movement_particle_attractor_transform():
	movement_particle_attractor.global_position = self.global_position
		
	if Global.player.global_input_dir:
		var norm_player_input_dir = Global.player.global_input_dir.normalized()
		var law_of_cos = func (a, b, c) -> float: return acos((a*a + b*b - c*c) / (2*a))
		var angle = 0
		angle = law_of_cos.call(1, 1, Vector3.FORWARD.distance_to(norm_player_input_dir))
		if norm_player_input_dir.x > 0:
			angle = -angle
		if Global.player.sprinting:
			movement_particle_attractor.strength = -7.5
		else:
			movement_particle_attractor.strength = -5
		
		# Particle attractor is top level so that x and z rotation are not included
		# because the y rotation is the only thing needed when walking around
		movement_particle_attractor.rotation.y = Global.player.cam.rotation.y + angle
	else:
		movement_particle_attractor.strength = 0.0


func update_rotation_particle_attractor_transform():
	rotation_particle_attractor.global_position = self.global_position
	
	var cam_rot: Vector3 = Global.player.cam.rotation
	var cam_rot_offset: Vector3 = cam_rot - cam_rot_last_frame
	
	# Compensate for cam rotation wrapping between -2PI and 0
	if cam_rot_offset.y > PI:
		cam_rot_offset.y -= TAU
	elif cam_rot_offset.y < -PI:
		cam_rot_offset.y += TAU
		
	#var norm_cam_rot_offset_y = (abs(cam_rot_offset.y) - 0.1) / (0.25 - 0.1)
	#if abs(cam_rot_offset.y) > 0.2 and swoosh_timer.is_stopped():
	#	swoosh_player.volume_db = lerp(-17.5, 6.0, norm_cam_rot_offset_y)
	#	swoosh_player.play()
	#	swoosh_timer.start()
		
	if abs(cam_rot_offset.y) > 0.0001:
		rotation_particle_attractor.strength = lerp(rotation_particle_attractor.strength, cam_rot_offset.y * 250.0, 0.1)
		rotation_particle_attractor.rotation.y = Global.player.cam.rotation.y - PI/2.0
	else:
		rotation_particle_attractor.strength = lerp(rotation_particle_attractor.strength, 0.0, 0.1)
		
	cam_rot_last_frame = cam_rot


func light_torch():
	var player_light = Global.player.light
	
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(burning_player, "volume_db", -5.0, 3.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(player_light, "omni_range", default_range, 3.0).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(player_light, "default_energy", default_energy, 3.0)
	tween.parallel().tween_property(particles.process_material, "initial_velocity", Vector2.ONE, 3.0).from(Vector2.ZERO)
	tween.parallel().tween_property(particles.process_material, "scale", Vector2.ONE, 3.0).from(Vector2.ZERO)
	
	player_light.flicker()
	particles.emitting = true
	is_lit = true
	
	get_tree().call_group("fire_sources", "set_interactable", false)
