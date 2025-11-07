class_name PlayerTorch
extends Interactable

signal picked_up

const MIN_IMPACT_VEL = 1
const MOMENT_OF_INERTIA = 0.21333
const MAX_KE = 50
const MIN_PITCH = 0.8
const MAX_PITCH = 1
const MIN_HIT_VOL = -5
const MAX_HIT_VOL = 5

const HOLD_SCALE = Vector3.ONE * 0.35
const HOLD_Y_POS = -0.095

const BURNING_PLAYER_DEF_VOLUME = -5.0

var flicker_intensity = 1.2

var cam_rot_last_frame := Vector3.ZERO

var hit_sound_timer = Timer.new()

var is_lit = false
var held_by_player = false
var looked_at_last_frame = false

@export var default_range: float = 12.0
@export var default_energy: float = 1.25

@onready var material = $Mesh.material_overlay
@onready var self_light = $SelfLight
@onready var pickup_player = $PickupPlayer
@onready var swoosh_player: AudioStreamPlayer3D = $SwooshPlayer
@onready var movement_particle_attractor: GPUParticlesAttractorSphere3D = $MovementParticleAttractor
@onready var rotation_particle_attractor: GPUParticlesAttractorSphere3D = $RotationParticleAttractor
@onready var interact_area = $InteractArea
@onready var mesh = meshes[0]
@onready var swoosh_timer = Timer.new()
@onready var fire: Fire = $Fire


func _ready() -> void:
	super()
	
	Global.torch = self
	# All fire burning sound players are synced off the playback position of the player torch
	# so it must be playing at all times rather than be paused
	fire.burning_player.volume_db = -80.0
	
	self_light.default_energy = 1.0
	fire.particles.emitting = false
	fire.particles.layers = 2
	fire.light.do_visible_notifier_update = false
	fire.light.omni_shadow_mode = OmniLight3D.SHADOW_CUBE
	fire.light.layers = 3
	self_light.visible = false
	hit_sound_timer.wait_time = 0.2
	hit_sound_timer.one_shot = true
	swoosh_timer.one_shot = true
	swoosh_timer.wait_time = 0.2
	add_child(swoosh_timer)
	
	SaveManager.loaded.connect(_on_loaded_from_save)


func _process(_delta: float) -> void:
	calculate_fire_up_dir()
	update_movement_particle_attractor_transform()
	#update_rotation_particle_attractor_transform(delta) ## TODO: Come back to this
	
	if held_by_player:
		#global_position = Global.player.torch_marker.global_position
		#global_rotation = Global.player.torch_marker.global_rotation
		global_transform = Global.player.torch_marker.global_transform


func _on_interact() -> void:
	held_by_player = true
	
	pickup_player.play()
	fire.particles.local_coords = true
	mesh.layers = 2
	self_light.visible = true
	
	highlight_light.visible = false
	
	set_interactable(false)
	_untarget()
	
	mesh.scale = HOLD_SCALE
	fire.particles.scale = HOLD_SCALE
	mesh.position.y = HOLD_Y_POS
	
	if not Global.player.debug_has_torch:
		Global.ui.hint_popup("Find a way to light the torch", 5.0)
	
	picked_up.emit()
	get_tree().call_group("fire_sources", "update_interactable")


func calculate_fire_up_dir():
	fire.particles.process_material.direction = Vector3.UP.rotated(Vector3.LEFT, global_rotation.x)


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
		movement_particle_attractor.rotation.y = Global.camera_controller.rotation.y + angle
	else:
		movement_particle_attractor.strength = 0.0


func update_rotation_particle_attractor_transform(delta: float):
	rotation_particle_attractor.global_position = self.global_position
	
	var cam_rot: Vector3 = Global.camera_controller.rotation
	var cam_rot_offset: Vector3 = (cam_rot - cam_rot_last_frame)
	
	# Compensate for cam rotation wrapping between -2PI and 
	
	var rotation_velocity: float = cam_rot_offset.y / delta
		
	if abs(rotation_velocity) > 0.0001:
		rotation_particle_attractor.strength = rotation_velocity * 10# move_toward(rotation_particle_attractor.strength, rotation_velocity, delta * 1500.0)
		rotation_particle_attractor.rotation.y = Global.camera_controller.rotation.y - PI/2.0
	else:
		rotation_particle_attractor.strength = 0.0# move_toward(rotation_particle_attractor.strength, 0.0, delta * 500.0)
		
	cam_rot_last_frame = cam_rot


func light_torch():
	fire.burning_player.play()
	
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(fire.burning_player, "volume_db", BURNING_PLAYER_DEF_VOLUME, 3.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fire.light, "omni_range", default_range, 3.0).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(fire.light, "default_energy", default_energy, 3.0)
	tween.parallel().tween_property(self_light, "omni_range", 1.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self_light, "default_energy", 1.0, 3.0)
	tween.parallel().tween_property(fire.particles.process_material, "initial_velocity", Vector2.ONE, 3.0).from(Vector2.ZERO)
	tween.parallel().tween_property(fire.particles.process_material, "scale", Vector2.ONE, 3.0).from(Vector2.ZERO)
	
	fire.light.enable_flicker = true
	fire.light.flicker()
	fire.particles.emitting = true
	is_lit = true
	
	get_tree().call_group("fire_sources", "set_interactable", false)


func _on_loaded_from_save():
	if held_by_player:
		fire.light.omni_range = default_range
		fire.light.default_energy = default_energy
		fire.burning_player.volume_db = BURNING_PLAYER_DEF_VOLUME
		fire.burning_player.play()
		picked_up.emit()
		fire.light.flicker()
		get_tree().call_group("fire_sources", "update_interactable")


func get_save_properties():
	var props: Array[String] = super()
	props.append_array([
		"mesh:scale",
		"mesh:position",
		"mesh:layers",
		"fire:particles:scale",
		"fire:particles:emitting",
		"fire:particles:local_coords",
		"fire:light:omni_range",
		"fire:light:default_energy",
		"self_light:visible",
		"held_by_player",
		"is_lit",
		"fire:burning_player:volume_db",
		"fire:light:enable_flicker",
	])
	return props
