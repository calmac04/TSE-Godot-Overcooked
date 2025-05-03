extends MeshInstance3D

@onready var timer = $CookingTimer
@onready var burningTimer = $BurningTimer

var ingredients = []
var current_ingredient = null
var isValidRecipe = true
var isFinishedCooking = true
	
func _input(event):
	if event is InputEventKey and event.pressed and isFinishedCooking:
		#When plate is finished programming, this will pass in the ingredients on the plate instead	
		_AddFood(event.keycode)
		
	
		
func _AddFood(food):
	if current_ingredient == null: #Gets the current ingredient to ensure player cannot put wrong dish together
			print("Starting timer")
			current_ingredient = food 
			isFinishedCooking = false
			timer.start()
			
	if (ingredients.size() <= 3) and (food == current_ingredient):
		ingredients.append(food)
		
		if ingredients.size() > 1 and (timer.time_left < 3.0):
			timer.start(timer.time_left + 2.0)
			print("Timer increased to:", timer.time_left)
	if (ingredients.size() <= 3):
		print("FULL")
	if (food != current_ingredient):
		print("NOT MATCHING INGREDIENTS")	

func _on_cooking_timer_timeout():
	print("COOKED")
	isFinishedCooking = true
	timer.stop()
	burningTimer.start()
	
			
func _on_burning_timer_timeout():
	print("BURNT")
	burningTimer.stop()
	

	
	
