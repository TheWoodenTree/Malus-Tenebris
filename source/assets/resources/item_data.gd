class_name ItemData
extends Resource

# Set by pickup script
var mesh: MeshInstance3D : set = _set_mesh
var count: int = 1

@export var name: String = ""
@export var texture: CompressedTexture2D = null
@export var pickup_sound: AudioStream = null
@export var hold_rotation_offset: Vector3 = Vector3.ZERO
@export var hold_scale_multiplier: float = 1.0


func _set_mesh(new_mesh: MeshInstance3D):
	mesh = new_mesh
	mesh.material_overlay = null
	mesh.layers = 2


func reset():
	name = ""
	texture = null
	pickup_sound = null
	hold_rotation_offset = Vector3.ZERO
	hold_scale_multiplier = 1.0
