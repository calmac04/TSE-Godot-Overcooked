extends Node

@export var to_spawn: PackedScene
var on_cooker: Node = null

@onready var cooker_top = $CookerTop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if to_spawn:
		var spawning_item = to_spawn.instantiate()
		if spawning_item is RigidBody3D:
			spawning_item.freeze = true
			place_item(spawning_item)

##Function to visually put the item on the cooker			
func place_item(item):
	if not on_cooker:
		on_cooker = item
		
		cooker_top.add_child(item)
		item.transform = Transform3D.IDENTITY #Will reset rotation/position relative to hold position
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		
		#Switches saucepan state to on_cooker
		if item.has_method("set_on_cooker"):
			item.set_on_cooker(true)
		
		print(item.name + " on cooker")
	else:
		print("Can't place on cooker")
		
#Checks to see if board is full
func is_full() -> bool:
	if on_cooker:
		return true
	else:
		return false

##Returns a copy of the item on the cooker
func get_item() -> Node:
	var item_to_return = on_cooker
	return item_to_return
	
func remove_item():
	if on_cooker.has_method("set_on_cooker"):
		on_cooker.set_on_cooker(false)
	on_cooker = null
	
