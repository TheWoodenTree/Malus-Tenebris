class_name Interactable
extends Node3D

enum Type {DOOR, DRAGGABLE, LOCKED_DOOR, PICKUP, NOTE, MOVEABLE, FIRE, MISC}

@export var interactable_type: Type = Type.MISC
@export var interact_areas: Array[InteractArea]
@export var meshes: Array[MeshInstance3D]
@export var interactable: bool = true : set = set_interactable
@export var enable_highlight_light: bool = false : set = _set_enable_highlight_light
@export var enable_highlight_sheen: bool = false : set = _set_enable_highlight_sheen
@export_enum("Outline", "Highlight") var shader_mode: String = "Outline"

var being_targeted: bool = false

var outline_material: ShaderMaterial = preload("res://source/assets/shaders/outline_shader_mat.tres")
var highlight_material: ShaderMaterial = preload("res://source/assets/shaders/highlight_shader_mat.tres")

@onready var highlight_light = $highlight_light if has_node("highlight_light") else null


func _ready():
	if highlight_light:
		highlight_light.visible = enable_highlight_light
	
	for area: InteractArea in interact_areas:
		area.set_collision_layer_value(16, interactable)
		area.interact_ray_collided.connect(_target)
		area.interact_ray_stopped_colliding.connect(_untarget)
		area.allow_sheen_area_entered.connect(enable_sheen)
		area.allow_sheen_area_exited.connect(disable_sheen)


func _target():
	being_targeted = true
	for mesh: MeshInstance3D in meshes:
		if shader_mode == "Outline":
			mesh.material_overlay.set_shader_parameter("outlineOn", true)
		else:
			mesh.material_override = highlight_material
	Global.player.set_targeted_interactable(self)
	_on_target()


func _untarget():
	being_targeted = false
	for mesh: MeshInstance3D in meshes:
		if shader_mode == "Outline":
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


func interact():
	enable_highlight_sheen = false
	disable_sheen()


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


func _set_enable_highlight_sheen(enable_: bool):
	enable_highlight_sheen = enable_
