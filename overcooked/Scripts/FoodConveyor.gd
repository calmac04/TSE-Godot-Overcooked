extends Node

var on_conveyor: Node = null
var item_deleted: bool = false
var plate_warmer: Node = null

func _ready():
	#Get the waste baskets in the scene
	var pw_group = get_tree().get_nodes_in_group("PlateWarmer")
	if pw_group.size() > 0:
		plate_warmer = pw_group[0]
		
#Bool value to let player know to set held_object to NULL if remove_item() is called
func place_item(item: Node) -> bool:
	item_deleted = false
	if not on_conveyor:
		on_conveyor = item
		#add_child(item)
		item.transform = Transform3D.IDENTITY
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		
		check_order(item)
		return item_deleted
	else:
		print("Conveyor holding" + on_conveyor.name)
		return false
		
func check_order(item : Node):
	if item.is_in_group("Plate"):
		var food = item.get_item()
		Recipes.removerecipe(food.foodType)
		if food.foodType == "onion_soup":
			accept_item(item)
		else:
			reject_item(item)
	else:
		on_conveyor = null
		item_deleted = false
		print("NEED A PLATE")
			
func accept_item(item : Node):
	if item:
		print("ORDER ACCEPTED")
		remove_item()

func reject_item(item : Node):
	if item:
		print("ORDER REJECTED")
		remove_item()
	
	
func remove_item():
	if on_conveyor:
		item_deleted = true
		on_conveyor.queue_free()
		on_conveyor = null
		if plate_warmer:
			plate_warmer.add_plate()
	
