class_name Pickup
extends Interactable

signal picked_up

@export var item_data: ItemData
@export var name_override: String = ""
@export_range(0, 99) var count: int = 1

@onready var pickup_player = $PickupPlayer


func _ready():
	super()
	if item_data:
		item_data.mesh = meshes[0].duplicate()
	else:
		item_data = ItemData.new()
		
	if name_override:
		item_data.name = name_override
	
	item_data.count = count
	
	pickup_player.stream = item_data.pickup_sound
	
	if shader_mode == "Highlight":
		for mesh: MeshInstance3D in meshes:
			mesh.material_overlay.set_shader_parameter("outlineOn", false)


func interact():
	if interactable:
		set_interactable(false)
		
		Global.player.inventory_add_item(item_data)
		
		var pickup_string: String = "Picked up %s" % item_data.name
		if item_data.count > 1:
			pickup_string += " x%d" % item_data.count
		Global.ui.hint_popup(pickup_string, 3.0)
		
		highlight_light.visible = false
		for area: InteractArea in interact_areas:
			area.set_collision_layer_value(16, false)
		for mesh: MeshInstance3D in meshes:
			mesh.visible = false
		
		picked_up.emit()
		
		await Global.player.play_pickup_sound(pickup_player)
		queue_free()
