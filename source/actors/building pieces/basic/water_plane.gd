@tool
extends Node3D

const DEF_NOISE_SIZE: int = 512
const DEF_PLANE_SIZE: int = 5

#@export var size: int = DEF_PLANE_SIZE : set = _set_size
#@export var noise: NoiseTexture2D

@onready var mesh: PlaneMesh = $plane.mesh


func _set_size(new_size):
	#size = new_size
	if mesh:
		mesh.size = Vector2(new_size, new_size)
		
		#var new_scale: Vector2i = Vector2i(int(new_size / DEF_PLANE_SIZE), int(new_size / DEF_PLANE_SIZE))
		#noise.width = DEF_NOISE_SIZE * new_scale.x
		#noise.height = DEF_NOISE_SIZE * new_scale.y
		
		#var shader: ShaderMaterial = mesh.material
		#shader.set_shader_parameter("noise", noise)
		#shader.set_shader_parameter("speed_scale", 1.0)

		$water_col_area/box.shape.size = Vector3(new_size, 1, new_size)


func _ready():
	#_set_size(size)
	pass
