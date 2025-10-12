@abstract
class_name NPCState
extends State

@export var nav_agent_target_desired_distance := 2.0

var nav_agent: NavigationAgent3D


func set_character(character_: CharacterBody3D):
	character = character_
	nav_agent = character.get_node('NavAgent')
	_on_set_character(character)
