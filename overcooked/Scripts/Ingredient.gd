extends RigidBody3D

#public variables
@export var foodType: String = "onion"

var isBurnt: bool = false
var isChopped: bool = false


func chop():
	if not isChopped:
		isChopped = true
		self.scale -= Vector3(0.5,0.5,0.5)
		print("The " + foodType + " is chopped")

func is_chopped() -> bool:
	return isChopped
