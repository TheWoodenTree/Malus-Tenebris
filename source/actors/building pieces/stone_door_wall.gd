extends Node3D

var torches_lit = false

@onready var fire1 = $TorchHolder/Fire
@onready var fire2 = $TorchHolder2/Fire
@onready var torch_light_player = $TorchLightPlayer
@onready var fire_lit_player1 = $FireLitPlayer
@onready var fire_lit_player2 = $FireLitPlayer2


func _ready() -> void:
	pass


func _on_fire_light_area_body_entered(body: Node) -> void:
	if not torches_lit and body == Global.player:
		fire1.get_node("FireParticles").emitting = true
		fire1.get_node("Light").visible = true
		fire2.get_node("FireParticles").emitting = true
		fire2.get_node("Light").visible = true
		
		torch_light_player.play("torch_light_anim")
		fire_lit_player1.play()
		fire_lit_player2.play()
		
		torches_lit = true
