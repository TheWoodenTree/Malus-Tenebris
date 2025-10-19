@abstract 
class_name Interactable 
extends Node3D

enum Type {
	DOOR, 
	DRAGGABLE, 
	LOCKED_DOOR, 
	PICKUP, 
	NOTE, 
	MOVEABLE, 
	FIRE, 
	MISC,
}

enum ShaderMode {
	OUTLINE, 
	HIGHLIGHT,
}

const OUTLINE_MATERIAL: ShaderMaterial = preload("res://source/assets/shaders/outline_shader_mat.tres")
const HIGHLIGHT_MATERIAL: ShaderMaterial = preload("res://source/assets/shaders/highlight_shader_mat.tres")

@export var interactable_type: Type = Type.MISC
@export var interact_areas: Array[InteractArea]
@export var meshes: Array[MeshInstance3D]
@export var interactable: bool = true : set = set_interactable
@export var disable_highlight_shader: bool = false
@export var enable_highlight_light: bool = false : set = _set_enable_highlight_light
@export var enable_highlight_sheen: bool = false : set = _set_enable_highlight_sheen
@export var shader_mode: ShaderMode = ShaderMode.OUTLINE

var is_targeted: bool = false

@onready var highlight_light = $HighlightLight if has_node("HighlightLight") else null


func _ready():
	if highlight_light:
		highlight_light.visible = enable_highlight_light
		
	if not Engine.is_editor_hint():
		for area: InteractArea in interact_areas:
			area.set_collision_layer_value(16, interactable)
			area.interact_ray_collided.connect(_target)
			area.interact_ray_stopped_colliding.connect(_untarget)
			area.allow_sheen_area_entered.connect(_on_allow_sheen_area_entered)
			area.allow_sheen_area_exited.connect(disable_sheen)


func _target():
	is_targeted = true
	if not disable_highlight_shader:
		for mesh: MeshInstance3D in meshes:
			if shader_mode == ShaderMode.OUTLINE:
				if mesh.material_overlay:
					mesh.material_overlay.set_shader_parameter("outlineOn", true)
			else:
				mesh.material_override = HIGHLIGHT_MATERIAL
	Global.player.set_targeted_interactable(self)
	_on_target()


func _untarget():
	is_targeted = false
	for mesh: MeshInstance3D in meshes:
		if shader_mode == ShaderMode.OUTLINE:
			if mesh.material_overlay:
					mesh.material_overlay.set_shader_parameter("outlineOn", false)
		else:
			mesh.material_override = null
	Global.player.set_targeted_interactable(null)
	_on_untarget()


func _on_target(): # Virtual
	pass


func _on_untarget(): # Virtual
	pass


func enable_sheen():
	if enable_highlight_sheen:
		for mesh in meshes:
			if mesh and mesh.material_overlay and mesh.material_overlay.next_pass:
				mesh.material_overlay.next_pass.set_shader_parameter("enableSheen", true)


func disable_sheen():
	for mesh in meshes:
		if mesh and mesh.material_overlay and mesh.material_overlay.next_pass:
			mesh.material_overlay.next_pass.set_shader_parameter("enableSheen", false)


func interact() -> void:
	enable_highlight_sheen = false
	if highlight_light:
		highlight_light.visible = false
	disable_sheen()
	_on_interact()


@abstract func _on_interact() -> void


func set_interactable(interactable_: bool):
	interactable = interactable_
	for area: InteractArea in interact_areas:
		if area:
			area.set_collision_layer_value(16, interactable)


func get_interactable_type():
	return interactable_type


func _set_enable_highlight_light(enable: bool):
	enable_highlight_light = enable
	if highlight_light:
		highlight_light.visible = enable_highlight_light


func _set_enable_highlight_sheen(enable: bool):
	enable_highlight_sheen = enable


func _on_allow_sheen_area_entered():
	if not interactable or (self is Pickup and (self as Pickup).being_held):
		return
	enable_sheen()
