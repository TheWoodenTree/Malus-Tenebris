extends Node3D
class_name Interactable

enum Type {DOOR, DRAGGABLE, LOCKED_DOOR, PICKUP, NOTE, MOVEABLE, FIRE, MISC}

# Set by child script
var interactable_type: Type

var _interact_area: InteractArea # Should  not be accessed by anything but this script

var being_looked_at: bool = false
var outline_on: bool = false

@export var interactable: bool = true : set = set_interactable


# Set this interactable's type and connect its interact_area to its interact function
# as well as provide the interact_area with a reference to this node
# We use signals here so we don't have to worry about having the interact_area be a direct child of
# whatever node has the interactable script attached; in the case of a door the interact_area
# is a child of the door rigid body rather than the root node since the door moves
func init(type: Type, interact_area: Area3D):
	interactable_type = type
	_interact_area = interact_area
	_interact_area.connect("interacted", Callable(self, "interact"))
	_interact_area.interactable_ancestor = self
	_interact_area.set_collision_layer_value(16, interactable)


func set_interactable(interactable_: bool):
	interactable = interactable_
	if _interact_area:
		_interact_area.set_collision_layer_value(16, interactable_)


func get_interactable_type():
	return interactable_type
