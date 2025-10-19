class_name Pickup
extends Interactable

signal picked_up

@export var item_data: ItemData
@export var name_override: String = ""

var being_held := false

@onready var pickup_player = $PickupPlayer


func _ready():
	super()
	if item_data:
		item_data.item_scene_path = scene_file_path
	else:
		item_data = ItemData.new()
		
	if name_override:
		item_data.name = name_override
		
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
