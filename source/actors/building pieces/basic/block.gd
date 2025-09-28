@tool
class_name Block
extends StaticBody3D

enum FloorType {STONE, WOOD, DEBRIS_STONE}

@export var size: Vector3 = Vector3.ONE : set = _set_size
@export var nav_walkable: bool = true : set = _set_nav_walkable
@export var show_nav_blocking_volume := false : set = _set_show_nav_blocking_volume
@export var global_triplanar: bool = true : set = _set_global_triplanar
@export var type: FloorType = FloorType.STONE

var nav_blocking_volume: NavigationObstacle3D = null

@onready var mesh = $Mesh.mesh
@onready var collision_box = $CollisionBox.shape


func _ready() -> void:
	mesh.size = size
	collision_box.extents = size / 2
	
	if not nav_walkable:
		_update_nav_blocking_volume()
		if nav_blocking_volume:
			nav_blocking_volume.show_volume = show_nav_blocking_volume
		
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
	if not nav_walkable and mesh:
		_update_nav_blocking_volume()
	elif has_node("NavBlockingVolume"):
			get_node("NavBlockingVolume").queue_free()	


func _set_show_nav_blocking_volume(show_nav_blocking_volume_: bool):
	show_nav_blocking_volume = show_nav_blocking_volume_
	if nav_blocking_volume:
		nav_blocking_volume.show_volume = show_nav_blocking_volume


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


func _update_nav_blocking_volume():
	nav_blocking_volume = load("res://source/actors/building pieces/basic/nav_blocking_volume.tscn").instantiate()
	add_child(nav_blocking_volume)
	nav_blocking_volume.position.y = size.y / 2.0
	nav_blocking_volume.size = Vector3(size.x, 1.0, size.z)
