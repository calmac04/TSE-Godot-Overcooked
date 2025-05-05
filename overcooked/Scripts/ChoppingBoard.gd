extends Node

var on_board: Node = null

@onready var counter_top = $CounterTop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

##Function to chop the food
func chop_food():
	if on_board and on_board.has_method("chop"):
		on_board.chop()
	else:
		print("Nothing to chop")
			

##Function to visually put the item on the chopping board			
func place_item(item):
	if not on_board:
		on_board = item
		
		counter_top.add_child(item)
		item.transform = Transform3D.IDENTITY #Will reset rotation/position relative to hold position
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		
		print(item.name + " on chopping board")
	else:
		print("Chopping table full")
		
#Checks to see if board is full
func is_full() -> bool:
	if on_board:
		return true
	else:
		return false

#Returns a copy of the current item on the chopping board
func get_item() -> Node:
	var item_copy = on_board
	return item_copy
	
func remove_item():
	on_board = null
	
