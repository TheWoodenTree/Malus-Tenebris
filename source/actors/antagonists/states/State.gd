@abstract
class_name State
extends Node

@warning_ignore("unused_signal")
signal transition(from_state: State, to_state_name: String)

var character: CharacterBody3D
var nav_agent: NavigationAgent3D


@abstract func enter()
@abstract func exit()


@warning_ignore("unused_parameter")
func update(delta: float):
	pass


@warning_ignore("unused_parameter")
func physics_update(delta: float):
	pass


func set_character(character_: CharacterBody3D):
	character = character_
	nav_agent = character.get_node('NavAgent')
	_on_set_character(character)


@warning_ignore("unused_parameter")
func _on_set_character(character_: CharacterBody3D):
	pass
