extends Node

@export var scene_spawn: PackedScene
@onready var tray_top = $TrayTop

var on_tray: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spawn_item() -> Node:
	if scene_spawn:
		var item_to_spawn = scene_spawn.instantiate()
		if item_to_spawn:
			print("Spawned item")
			return item_to_spawn
		else:
			print("ERROR SPAWNING ITEM")
			return null
	else:
		return null
		
func place_item(item):
	if not on_tray:
		on_tray = item
		
		tray_top.add_child(item)
		item.transform = Transform3D.IDENTITY #Will reset rotation/position relative to hold position
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		
		print(item.name + " on tray")
	else:
		print("Tray full")
		
func get_item():
	var item_copy = on_tray
	return item_copy
	
func remove_item():
	on_tray = null
	
func is_full():
	if on_tray:
		return true
	else:
		return false
	
	
