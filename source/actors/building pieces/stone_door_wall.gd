extends Node3D

var torches_lit = false

@onready var fire1 = $torch_holder/fire
@onready var fire2 = $torch_holder2/fire
@onready var torch_light_player = $torch_light_player
@onready var fire_lit_player1 = $fire_lit_player
@onready var fire_lit_player2 = $fire_lit_player2


func _ready() -> void:
	pass


func _on_fire_light_area_body_entered(body: Node) -> void:
	if not torches_lit and body == Global.player:
		fire1.get_node("fire_particles").emitting = true
		fire1.get_node("light").visible = true
		fire2.get_node("fire_particles").emitting = true
		fire2.get_node("light").visible = true
		
		torch_light_player.play("torch_light_anim")
		fire_lit_player1.play()
		fire_lit_player2.play()
		
		torches_lit = true
