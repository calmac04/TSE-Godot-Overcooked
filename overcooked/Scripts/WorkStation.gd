extends Node

@export var scene_spawn: PackedScene
var on_board: Node = null

@onready var counter_top = $CounterTop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if scene_spawn:
		var starting_object = scene_spawn.instantiate()
		if starting_object is RigidBody3D:
			starting_object.freeze = true
		place_item(starting_object)

##Function to visually put the item on the work station		
func place_item(item):
	if not on_board:
		on_board = item
		
		counter_top.add_child(item)
		item.transform = Transform3D.IDENTITY #Will reset rotation/position relative to hold position
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		
		print(item.name + " on work station")
	else:
		print("Work station full")
		
#Checks to see if board is full
func is_full() -> bool:
	if on_board:
		return true
	else:
		return false

##Returns a copy of item
func get_item() -> Node:
	var item_to_return = on_board
	return item_to_return
	
func remove_item():
	on_board = null
	
