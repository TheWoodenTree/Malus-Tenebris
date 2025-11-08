extends Node3D

@onready var monster: CharacterBody3D = $Monster
@onready var nav_region: NavigationRegion3D = $NavRegion


func _ready() -> void:
	Global.world = self
	Global.monster = monster
	Global.nav_region = nav_region
