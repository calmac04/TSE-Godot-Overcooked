extends Node

var on_plate: Node = null

@onready var plate_top = $PlateTop

#Adds item to plate
func place_item(item: Node):
	if not on_plate:
		on_plate = item
			
		plate_top.add_child(item)
		item.transform = Transform3D.IDENTITY #Will reset rotation/position relative to hold position
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		print(item.name + " on plate")
	else:
		print("Can't place on plate")

func is_full() -> bool:
	if on_plate:
		return true
	else:
		return false

func get_item():
	#Copies item so that the plate can be empty without deleting the original item
	var item_copy = on_plate
	return item_copy
	
func remove_item():
	on_plate = null
	
