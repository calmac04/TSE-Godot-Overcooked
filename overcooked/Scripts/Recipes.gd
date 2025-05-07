extends Node
var recipelist = []
var timerval = 0
var frametime = 0
var rng = RandomNumberGenerator.new()
var randomtimer = rng.randf_range(0.0, 10.0)
var score = 0
var level = 0
var time = 300
@export var timer: RichTextLabel
@export var points: RichTextLabel

func _physics_process(delta):
	var root = get_tree().root
	var current_scene = root.get_child(-1)
	var manager = current_scene.get_node("Camera3D/Control/RecipeLocs/GUIManager")
	timer = current_scene.get_node("Camera3D/Control/TimeElement/TimeText")
	points = current_scene.get_node("Camera3D/Control/MoneyElement/CoinText")
	if level == 1 or level == 2 or level == 3:
		manager.shift_recipes_left_if_needed()
		frametime = frametime + 1
		if frametime > 60:
			frametime = 0
			time = time - 1
			timer.text = str(time)
			if time <= 0:
				get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
			timerval = timerval + 1
			#print(timerval)
			if timerval >= randomtimer:
				timerval = 0
				randomtimer = rng.randf_range(15.0, 30.0)
				#print(randomtimer)
				var item = ["onion_soup",50]
				if recipelist.size() < 5:
					recipelist.append(item)
					manager.handle_recipe_shift_and_spawn()
			for n in recipelist:
				if n[1] == 0:
					recipelist.erase(n)
					print("recipe failed")
					score = score - 25
					points.text = str(score)
				n[1] = n[1] - 1
			print(recipelist)
	pass

func removerecipe(dish):
	var root = get_tree().root
	var current_scene = root.get_child(-1)
	var manager = current_scene.get_node("Camera3D/Control/RecipeLocs/GUIManager")
	points = current_scene.get_node("Camera3D/Control/MoneyElement/CoinText")
	print(dish, recipelist)
	for n in recipelist:
		if n[0] == dish:
			score = score + n[1]
			points.text = str(score)
			recipelist.erase(n)
			manager.remove("Onion Recipe")
		break
	pass
