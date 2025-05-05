extends Control

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/LevelSelect.tscn")
	
func on_options_pressed():
	print("Options Pressed")
	
func on_quit_pressed():
	get_tree().quit()





func _on_level_1_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
