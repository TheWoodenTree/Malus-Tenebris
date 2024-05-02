class_name Pickup
extends Interactable

@export var item_data: ItemData
@export var name_override: String = ""
@export_range(0, 99) var count: int = 1

@onready var pickup_player = $pickup_player
@onready var interact_area = $interact_area
@onready var mesh = $mesh


func _ready():
	super()
	init(Type.PICKUP, interact_area, [mesh])
	if item_data:
		item_data.mesh = mesh.duplicate()
	else:
		item_data = ItemData.new()
		
	if name_override:
		item_data.name = name_override
	
	item_data.count = count
	
	if shader_mode == "Highlight":
		mesh.material_overlay.set_shader_parameter("outlineOn", false)


func _process(_delta):
	if being_looked_at and not Global.player.held_item: # Is the second condition necessary?
		mesh.material_overlay.set_shader_parameter("outlineOn", true)
		for child in get_children():
			if child is MeshInstance3D and shader_mode == "Outline" and child.material_overlay:
				child.material_overlay.set_shader_parameter("outlineOn", true)
			elif child is MeshInstance3D and shader_mode == "Highlight" and not child.material_override:
				child.material_override = highlight_material
		outline_on = true
	elif outline_on:
		for child in get_children():
			if child is MeshInstance3D and shader_mode == "Outline" and child.material_overlay:
				child.material_overlay.set_shader_parameter("outlineOn", false)
			elif child is MeshInstance3D and shader_mode == "Highlight" and child.material_override:
				child.material_override = null
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
