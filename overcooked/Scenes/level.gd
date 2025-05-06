extends Node3D

func _physics_process(delta):
	if get_tree().current_scene.name == "level":
		Recipes.level = 1
	elif get_tree().current_scene.name == "level_2":
		Recipes.level = 2
	elif get_tree().current_scene.name == "level_3":
		Recipes.level = 3
