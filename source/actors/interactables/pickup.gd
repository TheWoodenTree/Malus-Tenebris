extends Interactable
class_name Pickup

@onready var mesh = $mesh
@onready var pickup_player = $pickup_player
@onready var interact_area = $interact_area
@onready var highlight_light = $highlight_light

@export var item_data: ItemData
@export var name_override: String = ""
@export var highlight_light_on: bool = false
@export_range(0, 99) var count: int = 1


func _ready():
	init(Type.PICKUP, interact_area)
	if item_data:
		item_data.mesh = mesh.duplicate()
	else:
		item_data = ItemData.new()
		
	if name_override:
		item_data.name = name_override
	
	highlight_light.visible = highlight_light_on
	item_data.count = count


func _process(_delta):
	if being_looked_at and not Global.player.held_item: # Is the second condition necessary?
		mesh.material_overlay.set_shader_parameter("outlineOn", true)
		for child in get_children():
			if child is MeshInstance3D and child.material_overlay:
				child.material_overlay.set_shader_parameter("outlineOn", true)
		outline_on = true
	elif outline_on:
		for child in get_children():
			if child is MeshInstance3D and child.material_overlay:
				child.material_overlay.set_shader_parameter("outlineOn", false)
		outline_on = false


func interact():
	if interactable and not Global.player.held_item: # Is the second condition necessary?
		Global.player.inventory_add_item(item_data)
		var pickup_string: String = "Picked up %s" % item_data.name
		if item_data.count > 1:
			pickup_string += " x%d" % item_data.count
		Global.ui.hint_popup(pickup_string, 3.0)
		set_interactable(false)
		mesh.visible = false
		highlight_light.visible = false
		interact_area.set_collision_layer_value(16, false)
		await Global.player.play_pickup_sound(pickup_player)
		queue_free()