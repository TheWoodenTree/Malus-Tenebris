class_name Pickup
extends Interactable

signal picked_up

const ITEM_DATA_RESOURCES = {
	ItemRegistry.ID.NONE: null,
	ItemRegistry.ID.RUBOLEUM_VIAL: preload("uid://dq2xpjjilobj"),
	ItemRegistry.ID.BANDAGE: preload("uid://d26ds3d235e2e"),
	ItemRegistry.ID.HOURGLASS: preload("uid://binua2vubahmw"),
	ItemRegistry.ID.JOURNAL: preload("uid://bqtcwaf610b65"),
	ItemRegistry.ID.WINCH_CRANK: preload("uid://8ou378eo38r2"),
	ItemRegistry.ID.BEEF_FAT: preload("uid://bm4qj337mcios"),
	ItemRegistry.ID.CELL_HALL_KEY: preload("uid://c8opu2jmkysqx"),
	ItemRegistry.ID.SUMP_TUNNELS_KEY: preload("uid://ddwrs221n0xxx"),
	ItemRegistry.ID.LARDER_KEY: preload("uid://bqar0bonuyvsp"),
}

@export var item_id := ItemRegistry.ID.NONE

var being_held := false
var item_data: ItemData

@onready var pickup_player = $PickupPlayer


func _ready():
	super()
	
	item_data = ITEM_DATA_RESOURCES[item_id]
	if item_data:
		item_data.item_scene_path = scene_file_path
	else:
		push_error("Null item data on " + str(get_path()))
		item_data = ItemData.new()
		
	pickup_player.stream = item_data.pickup_sound
	
	if shader_mode == ShaderMode.HIGHLIGHT:
		for mesh: MeshInstance3D in meshes:
			if mesh.material_overlay:
				mesh.material_overlay.set_shader_parameter("outlineOn", false)


func _on_interact():
	if interactable:
		set_interactable(false)
		
		for propery: StringName in item_data.copy_properties:
			item_data.copied_properties[propery] = get(propery)
		
		Global.player.inventory_add_item(item_data)
		
		var pickup_string: String = "Picked up %s" % item_data.name
		Global.ui.hint_popup(pickup_string, 3.0)
		
		highlight_light.visible = false
		visible = false
		for area: InteractArea in interact_areas:
			area.set_collision_layer_value(16, false)
		
		picked_up.emit()
		
		item_data.item_instance = load(item_data.item_scene_path).instantiate()
		
		await Global.player.play_pickup_sound(pickup_player)
		queue_free()
