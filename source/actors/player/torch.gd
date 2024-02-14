extends Interactable

const MIN_IMPACT_VEL = 1
const MOMENT_OF_INERTIA = 0.21333
const MAX_KE = 50
const MIN_PITCH = 0.8
const MAX_PITCH = 1
const MIN_HIT_VOL = -5
const MAX_HIT_VOL = 5

var flicker_intensity = 1.2

var timer = Timer.new()
var hit_sound_timer = Timer.new()

var is_lit = false
var held_by_player = false
var looked_at_last_frame = false

var impact_sounds: Array
var impact_player = preload("res://source/assets/sounds/impacts/impact_player.tscn")

@export var default_range: float = 12.0
@export var default_energy: float = 1.25

@onready var flicker_low = default_energy / flicker_intensity
@onready var flicker_high = default_energy * flicker_intensity
@onready var mesh = $mesh
@onready var material = $mesh.material_overlay
@onready var particles = $fire_particles
@onready var light = $fire_particles/light
@onready var torch_light_player = $torch_light_player
@onready var pickup_player = $pickup_player
@onready var burning_player = $burning_player
@onready var lit_particles = $lit_fire_particles
@onready var particle_attractor: GPUParticlesAttractorSphere3D = $particle_attractor
@onready var interact_area = $interact_area
@onready var highlight_light = $highlight_light


func _ready() -> void:
	init(Type.PICKUP, interact_area)
	mesh.mesh.surface_get_material(0).albedo_color = Color.WHITE
	light.omni_range = default_range
	light.light_energy = default_energy
	timer.one_shot = true
	particles.emitting = false
	light.visible = false
	hit_sound_timer.wait_time = 0.2
	hit_sound_timer.one_shot = true
	add_child(timer)
	add_child(hit_sound_timer)
	_load_sounds()
	_flicker()


func _load_sounds():
	for i in range (1, 4):
		var sound = load("res://source/assets/sounds/impacts/small_wood_impact%d.ogg" % i)
		impact_sounds.append(sound)


func _process(_delta: float) -> void:
	calculate_fire_up_dir()
	update_particle_attractor_transform()
	
	if held_by_player:
		#global_position = Global.player.torch_pos.global_position
		#rotation = Global.player.torch_pos.rotation
		global_transform = Global.player.torch_pos.global_transform
	
	# Enable interaction outline if being looked at
	material.set_shader_parameter("outlineOn", being_looked_at)


func interact():
	held_by_player = true
	Global.player.torch = self
	Global.player.has_torch = true
	get_tree().call_group("fire_sources", "update_interactable")
	
	pickup_player.play()
	mesh.mesh.surface_get_material(0).albedo_color = Color.WEB_GRAY
	particles.local_coords = true
	mesh.layers = 2
	light.visible = false
	
	highlight_light.visible = false
	
	if not Global.player.debug_has_torch:
		Global.ui.hint_popup("Find a way to light the torch", 5.0)


func calculate_fire_up_dir():
	#var global_rot = global_transform.basis.get_euler()
	#particles.rotation.x = -global_rot.x
	#particles.rotation.z = -global_rot.z
	#print(Vector3.UP.rotated(Vector3.LEFT, global_rotation.x))
	particles.process_material.direction = Vector3.UP.rotated(Vector3.LEFT, global_rotation.x)


func update_particle_attractor_transform():
	particle_attractor.global_position = self.global_position
	if Global.player.global_input_dir != Vector3.ZERO:
		var norm_player_input_dir = Global.player.global_input_dir.normalized()
		var law_of_cos = func (a, b, c) -> float:
			return acos((a*a + b*b - c*c) / (2*a))
		var angle = 0
		angle = law_of_cos.call(1, 1, Vector3.FORWARD.distance_to(norm_player_input_dir))
		if norm_player_input_dir.x > 0:
			angle = -angle
		if Global.player.sprinting:
			particle_attractor.strength = -7.5
		else:
			particle_attractor.strength = -5
		
		# Particle attractor is top level so that x and z rotation are not included
		# because the y rotation is the only thing needed when walking around
		particle_attractor.rotation.y = Global.player.cam.rotation.y + angle
	else:
		particle_attractor.strength = 0


func _flicker():
	var flicker_duration = randf_range(0.1, 0.2)
	var intensity = randf_range(0, 1)
	var energy_flicker = lerp(flicker_low, flicker_high, intensity)
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(light, "light_energy", \
		energy_flicker, flicker_duration)
	flicker_tween.tween_callback(Callable(self,"_flicker"))


#warning-ignore:FUNCTION_CONFLICTS_VARIABLE
func light_torch():
	var player_light = Global.player.light
	torch_light_player.play()
	burning_player.play()
	player_light.default_range = default_range
	player_light.default_energy = default_energy
	player_light.omni_range = default_range
	player_light.light_energy = default_energy
	player_light.flicker()
	var torch_light_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	torch_light_tween.tween_property(player_light, "omni_range", default_range + 5, 0.3)
	torch_light_tween.tween_property(player_light, "omni_range", default_range, 0.7)
	particles.emitting = true
	lit_particles.emitting = true
	is_lit = true
	get_tree().call_group("fire_sources", "set_interactable", false)
