class_name ItemData
extends Resource

var item_instance: Pickup = null :
	set(value):
		item_instance = value
		if item_instance:
			set_copied_properties()
			item_instance.set_interactable(false)

# Set by pickup script
var item_scene_path: String = ""
var copied_properties: Dictionary[StringName, Variant] = {} 

@export var name: String = ""
@export var texture: CompressedTexture2D = null
@export var pickup_sound: AudioStream = null
@export var self_useable: bool = false # Item can be used when not looking at another interactable
@export var hold_rotation_offset: Vector3 = Vector3.ZERO
@export var hold_scale_multiplier: float = 1.0
@export var copy_properties: Array[StringName] = ["meshes"]


func _init() -> void:
	resource_local_to_scene = true


func reset():
	name = ""
	texture = null
	pickup_sound = null
	hold_rotation_offset = Vector3.ZERO
	hold_scale_multiplier = 1.0


func set_copied_properties():
	for property: String in copied_properties.keys():
		if copied_properties[property] is Array:
			var arr: Array = []
			for value in copied_properties[property]:
				if value is Resource:
					arr.append(value.duplicate_deep(Resource.DEEP_DUPLICATE_ALL))
				else:
					arr.append(value)
			item_instance.set(property, arr)
		else:
			item_instance.set(property, copied_properties[property])
