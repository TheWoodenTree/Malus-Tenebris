extends Node3D

var being_looked_at = false

@export var key_name: String = "Default"

@onready var key_pickup_player = $key_pickup_player
@onready var interact_area = $interact_area
@onready var highlight_material = $key.material_overlay


func _process(_delta: float) -> void:
	if being_looked_at:
		highlight_material.set_shader_parameter("outlineOn", true)
	else:
		highlight_material.set_shader_parameter("outlineOn", false)


func interact():
	key_pickup_player.play()
	self.visible = false
	interact_area.set_collision_layer_value(16, false)
	Global.player.inventory.append(key_name)
	Global.ui.hint_popup("Aquired %s Key" % key_name, 3.0)
	await key_pickup_player.finished
	queue_free()
