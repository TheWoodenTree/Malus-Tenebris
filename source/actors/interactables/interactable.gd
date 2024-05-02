class_name Interactable
extends Node3D

enum Type {DOOR, DRAGGABLE, LOCKED_DOOR, PICKUP, NOTE, MOVEABLE, FIRE, MISC}

@export var interactable: bool = true : set = set_interactable
@export var enable_highlight_light: bool = false : set = _set_enable_highlight_light
@export var enable_highlight_sheen: bool = false : set = _set_enable_highlight_sheen
@export_enum("Outline", "Highlight") var shader_mode: String = "Outline"

# Set by child script
var interactable_type: Type

var _interact_area: InteractArea # Should  not be accessed by anything but this script

var meshes: Array[MeshInstance3D] # Meshes used by child interactable

var being_looked_at: bool = false
var outline_on: bool = false

var highlight_material: ShaderMaterial = preload("res://source/assets/shaders/highlight_shader_mat.tres")

@onready var highlight_light = $highlight_light if has_node("highlight_light") else null


func _ready():
	if highlight_light:
		highlight_light.visible = enable_highlight_light


# Set this interactable's type and connect its interact_area to its interact function
# as well as provide the interact_area with a reference to this node
# We use signals here so we don't have to worry about having the interact_area be a direct child of
# whatever node has the interactable script attached; in the case of a door the interact_area
# is a child of the door rigid body rather than the root node since the door moves
func init(type: Type, interact_area: Area3D, meshes_: Array[MeshInstance3D]):
	interactable_type = type
	_interact_area = interact_area
	_interact_area.connect("interacted", Callable(self, "interact"))
	_interact_area.interactable_ancestor = self
	_interact_area.set_collision_layer_value(16, interactable)
	
	meshes = meshes_
	if interactable:
		for mesh in meshes:
			if mesh and mesh.material_overlay and mesh.material_overlay.next_pass:
				mesh.material_overlay.next_pass.set_shader_parameter("enableSheen", enable_highlight_sheen)


func interact():
	for mesh in meshes:
		if mesh and mesh.material_overlay and mesh.material_overlay.next_pass:
			mesh.material_overlay.next_pass.set_shader_parameter("enableSheen", false)


func set_interactable(interactable_: bool):
	interactable = interactable_
	if _interact_area:
		_interact_area.set_collision_layer_value(16, interactable_)


func get_interactable_type():
	return interactable_type


func _set_enable_highlight_light(enable: bool):
	enable_highlight_light = enable
	if highlight_light:
		highlight_light.visible = enable_highlight_light


func _set_enable_highlight_sheen(enable_: bool):
	enable_highlight_sheen = enable_
