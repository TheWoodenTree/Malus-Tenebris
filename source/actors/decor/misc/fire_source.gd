@tool
class_name FireSource
extends Interactable

@export var default_range: float = 12.0
@export var default_energy: float = 0.75
@export var lit: bool = true : set = set_lit
@export var shadow_mode: OmniLight3D.ShadowMode = OmniLight3D.ShadowMode.SHADOW_DUAL_PARABOLOID : set = set_shadow_mode
@export var audio_fade_in_on_ready: bool = false

var burning_player: AudioStreamPlayer3D

@onready var fire = $fire
@onready var light = $fire/light
@onready var particles = $fire/fire_particles
@onready var interact_area = $interact_area
@onready var mesh = $mesh
@onready var detection_area = Area3D.new()


func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		if has_node("interact_area"):
			interact_area = $interact_area
		add_to_group("fire_sources")
		init(Type.FIRE, interact_area, [mesh])
		light.default_range = default_range
		light.omni_range = default_range
		light.default_energy = default_energy
		light.flicker()
		set_interactable(lit and is_instance_valid(Global.player.torch) and not Global.player.torch.is_lit)
		
		interact_area.fire_burning_sound_area_entered.connect(_on_fire_burning_sound_area_entered)
		interact_area.fire_burning_sound_area_exited.connect(_on_fire_burning_sound_area_exited)
		
		if audio_fade_in_on_ready:
			var tween = get_tree().create_tween()
			tween.tween_property(fire.burning_player, 'volume_db', 6.0, 5.0).from(-15.0)
		
	particles.emitting = lit
	light.visible = lit
	light.omni_shadow_mode = shadow_mode


func set_lit(is_lit):
	lit = is_lit
	$fire/fire_particles.emitting = lit
	$fire/light.visible = lit


func _process(_delta: float) -> void:
	if being_looked_at and interactable:
		if Global.player.has_torch and not Global.player.torch.is_lit:
			mesh.material_overlay.set_shader_parameter("outlineOn", true)
			outline_on = true
		elif outline_on and Global.player.has_torch and Global.player.torch.is_lit:
			mesh.material_overlay.set_shader_parameter("outlineOn", false)
			outline_on = false
	elif outline_on:
		mesh.material_overlay.set_shader_parameter("outlineOn", false)
		outline_on = false


func _on_fire_burning_sound_area_entered():
	if lit and fire.has_node("burning_player"):
		var start_time: float = Global.torch.burning_player.get_playback_position() + 30.0
		start_time = wrapf(start_time, 0.0, Global.torch.burning_player.stream.get_length())
		fire.burning_player.play(start_time)
		# Only render nearby lights on the second layer for performance
		# Second layer is for held items so they don't clip into walls
		#area.interactable_ancestor.fire.light.set_layer_mask_value(2, true)


func _on_fire_burning_sound_area_exited():
	if fire.has_node("burning_player"):
		fire.burning_player.stop()
	#fire.light.set_layer_mask_value(2, false)


func interact():
	if interactable and Global.player.has_torch and not Global.player.torch.is_lit:
		Global.player.torch.light_torch()


func set_shadow_mode(new_shadow_mode: OmniLight3D.ShadowMode):
	shadow_mode = new_shadow_mode
	$fire/light.omni_shadow_mode = new_shadow_mode


func update_interactable():
	set_interactable(lit and Global.player.torch and not Global.player.torch.is_lit)
