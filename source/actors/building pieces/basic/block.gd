@tool
class_name Block
extends StaticBody3D

enum FloorType {STONE, WOOD, DEBRIS_STONE}

@export var size: Vector3 = Vector3.ONE : set = _set_size
@export var nav_walkable: bool = true : set = _set_nav_walkable
@export var global_triplanar: bool = true : set = _set_global_triplanar
@export var type: FloorType = FloorType.STONE

@onready var mesh = $mesh.mesh
@onready var collision_box = $collision_box.shape


func _ready() -> void:
	mesh.size = size
	collision_box.extents = size / 2
	if not nav_walkable:
		var nav_blocking_volume = load("res://source/actors/building pieces/basic/nav_blocking_volume.tscn").instantiate()
		add_child(nav_blocking_volume)
		nav_blocking_volume.position.y = (mesh.size.y / 2) + 0.5
		nav_blocking_volume.get_node("mesh").mesh.size.x = size.x
		nav_blocking_volume.get_node("mesh").mesh.size.z = size.z
		nav_blocking_volume.get_node("collision_box").shape.extents.x = size.x / 2
		nav_blocking_volume.get_node("collision_box").shape.extents.z = size.z / 2
		if not Engine.is_editor_hint():
			nav_blocking_volume.visible = false
	if not global_triplanar and "wall" in name:
		mesh.material = load("res://source/assets/materials/bricks/bricks_local_triplanar.tres")
	elif not global_triplanar and "floor" in name:
		mesh.material = load("res://source/assets/materials/flagstone/flagstone_local_triplanar.tres")


func _set_size(new_state):
	size = new_state
	if mesh:
		mesh.size = new_state
	if collision_box:
		collision_box.extents = new_state / 2


func _set_nav_walkable(walkable):
	nav_walkable = walkable
	
	if not walkable and mesh:
		var nav_blocking_volume = load("res://source/actors/building pieces/basic/nav_blocking_volume.tscn").instantiate()
		add_child(nav_blocking_volume)
		nav_blocking_volume.position.y = (mesh.size.y / 2) + 0.5
		nav_blocking_volume.get_node("mesh").mesh.size.x = size.x
		nav_blocking_volume.get_node("mesh").mesh.size.z = size.z
		nav_blocking_volume.get_node("collision_box").shape.extents.x = size.x / 2
		nav_blocking_volume.get_node("collision_box").shape.extents.z = size.z / 2
	else:
		if has_node("nav_blocking_volume"):
			$nav_blocking_volume.queue_free()


func _set_global_triplanar(is_global):
	if is_global and not global_triplanar and mesh:
		if "wall" in name:
			mesh.material = load("res://source/assets/materials/tile_wall/tile_wall.tres")
		elif "floor" in name:
			mesh.material = load("res://source/assets/materials/tile/tile.tres")
	elif not is_global and global_triplanar and mesh:
		if "wall" in name:
			mesh.material = load("res://source/assets/materials/tile_wall/tile_wall_local_triplanar.tres")
		elif "floor" in name:
			mesh.material = load("res://source/assets/materials/tile/tile_local_triplanar.tres")
	global_triplanar = is_global
