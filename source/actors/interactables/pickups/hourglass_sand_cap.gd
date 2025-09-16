extends MeshInstance3D

@export var fill_proportion: float = 1.0 : set = set_fill_proportion
@export var volume_curve: Curve # Your hourglass curve
@export var radius_curve: Curve # Radius at each height
@export var is_top_half: bool = true
@export var segments: int = 32 # Circle resolution
@export var local_top: float = 0.246
@export var local_bottom: float = 0.0

func set_fill_proportion(value: float):
	fill_proportion = clamp(value, 0.0, 1.0)
	update_cap()

func _ready():
	update_cap()

func update_cap():
	if not volume_curve or not radius_curve:
		return
	
	# Get sand surface height from volume curve
	var sand_height: float
	if is_top_half:
		sand_height = volume_curve.sample(fill_proportion)
	else:
		sand_height = 1.0 - volume_curve.sample(1.0 - fill_proportion)
	
	# Convert to world height
	var world_height = local_bottom + sand_height * (local_top - local_bottom)
	
	# Get radius at this height from radius curve
	var radius = radius_curve.sample(sand_height)
	
	# Generate the cap mesh
	mesh = create_cap_mesh(radius, world_height)

func create_cap_mesh(radius: float, height: float) -> ArrayMesh:
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	# Center vertex
	vertices.append(Vector3(0, height, 0))
	normals.append(Vector3(0, 1 if is_top_half else -1, 0))
	uvs.append(Vector2(0.5, 0.5))
	
	# Ring vertices
	for i in range(segments):
		var angle = float(i) / float(segments) * TAU
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		
		vertices.append(Vector3(x, height, z))
		normals.append(Vector3(0, 1 if is_top_half else -1, 0))
		uvs.append(Vector2(0.5 + cos(angle) * 0.5, 0.5 + sin(angle) * 0.5))
	
	# Create triangles
	for i in range(segments):
		var next = (i + 1) % segments
		if is_top_half:
			indices.append_array([0, i + 1, next + 1])
		else:
			indices.append_array([0, next + 1, i + 1]) # Flip winding for bottom
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return array_mesh
