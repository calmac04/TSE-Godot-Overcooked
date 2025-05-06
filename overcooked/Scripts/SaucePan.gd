extends Node

@export var tomato_soup_scene: PackedScene
@export var onion_soup_scene: PackedScene
@export var mushroom_soup_scene: PackedScene

@onready var timer = $CookingTimer
@onready var burningTimer = $BurningTimer
@onready var smoke_effect = $CPUParticles3D
@onready var tomato_visualiser = $TomatoVisualiser

var ingredients = []
var current_ingredient = null
var isFinishedCooking: bool = true
var isBurnt: bool = false
var finished_product: Node = null
var is_on_cooker: bool = false
var timer_reset: bool = false

func set_on_cooker(state: bool):
	is_on_cooker = state
	
	if not is_on_cooker:
		timer.stop()
		burningTimer.stop()
		print("Removed from stove - not cooking")
	else:
		if not isFinishedCooking and ingredients.size() > 0:
			if timer_reset:
				timer.start(5.0)
			else:
				timer.start()
			print("Cooking continued")
		elif isFinishedCooking and ingredients.size() > 0 and (not isBurnt):
			burningTimer.start()
			print("Burning continued")
			
func add_food(food) -> bool:
	if isBurnt:
		print("Can't put food in when burning")
		return false
	if current_ingredient == null:
		current_ingredient = food
		
	if (ingredients.size() < 3) and (food == current_ingredient):
		ingredients.append(food)
		print("Added food: ", food)

		# Always (re)start the timer when an ingredient is added
		isFinishedCooking = false
		timer.stop()
		burningTimer.stop()
		if is_on_cooker:
			timer.start(5.0) #starts timer at 5 seconds
		else:
			timer_reset = true #indicates that timer should reset when placed on a stove again
		return true
	else:
		print("NOT MATCHING INGREDIENTS or FULL")
		return false

func return_food():
	if finished_product:
		if finished_product.get_parent():
			finished_product.get_parent().remove_child(finished_product)
		var item_to_return = finished_product
		finished_product = null
		print("Returned item " + item_to_return.name)
		return item_to_return
	else:
		return null

func _on_cooking_timer_timeout():
	print("COOKED")
	isFinishedCooking = true
	timer.stop()
	burningTimer.start(3.0)
	
	if ingredients.size() == 3:
		var ingredient_name = ingredients[0].to_lower()
		match ingredient_name:
			"onion":
				print("Made onion soup")
				finished_product = onion_soup_scene.instantiate()
			"tomato":
				print("Made tomato soup")
				finished_product = tomato_soup_scene.instantiate()
			"mushroom":
				print("Made mushroom soup")
				finished_product = mushroom_soup_scene.instantiate()
	if finished_product:
		clear_soup_visual()
		var rg: Node = finished_product as RigidBody3D
		rg.freeze = true
		tomato_visualiser.add_child(finished_product)
		
func _on_burning_timer_timeout():
	print("BURNT")
	burningTimer.stop()
	ingredients.clear()
	current_ingredient = null
	isFinishedCooking = true
	isBurnt = true
	
	smoke_effect.emitting = true

func is_burnt() -> bool:
	return isBurnt
	
func remove_item():
	print("Emptied")
	burningTimer.stop()
	timer.stop()
	ingredients.clear()
	current_ingredient = null
	finished_product = null
	isFinishedCooking = true
	timer_reset = true
	clear_soup_visual()

func put_out_fire():
	isBurnt = false
	smoke_effect.emitting = false
	
func clear_soup_visual():
	for child in tomato_visualiser.get_children():
		child.queue_free()
