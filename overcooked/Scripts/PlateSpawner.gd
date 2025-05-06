extends Node

@export var scene_spawn: PackedScene

var plates_on: Array = []
var plates_waiting: int = 0
var spawn_timer: float = 0.0
var waiting_time: float = 1.0

@onready var spawn_pos = [$Spawn1, $Spawn2, $Spawn3]

func _process(delta: float) -> void:
	if plates_waiting > 0 and plates_on.size() < 3:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_timer = waiting_time
			plates_waiting -= 1
			add_plate()
			
		
func add_plate():
	if plates_on.size() < 3:
		var plate = scene_spawn.instantiate()
		plates_on.append(plate)
		add_child(plate)
		plate.global_transform = spawn_pos[plates_on.size() - 1].global_transform
	else:
		plates_waiting += 1
		
func remove_plate() -> Node:
	if plates_on.size() > 0:
		var plate = plates_on.pop_back()
		plate.get_parent().remove_child(plate)
		return plate
	else:
		return null
		
		
