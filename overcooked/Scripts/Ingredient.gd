extends RigidBody3D

#public variables
@export var foodType: String = "onion"

var isBurnt: bool = false
var isChopped: bool = false


func chop():
	if not isChopped:
		isChopped = true
		print("The " + foodType + " is chopped")

func is_chopped() -> bool:
	return isChopped
