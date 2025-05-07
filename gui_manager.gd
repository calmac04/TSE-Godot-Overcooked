extends Node

@export var recipe_panel_scenes: Array[PackedScene]  # Assign .tscn scenes in Inspector
@onready var recipe_locs = get_node("../RecipeLocs")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		handle_recipe_shift_and_spawn()

func handle_recipe_shift_and_spawn():
	# Conveyor belt behavior: if first slot is empty, shift all left
	shift_recipes_left_if_needed()
	
	# Now try to spawn a new recipe
	spawn_new_recipe()

func shift_recipes_left_if_needed():
	var slots = recipe_locs.get_children()
	if slots.size() < 2:
		return  # Nothing to shift if only one slot exists

	# If the first slot is empty, shift all to the left
	if slots[0].get_child_count() == 0:
		for i in range(1, slots.size()):
			if slots[i].get_child_count() > 0:
				var recipe_panel = slots[i].get_child(0)
				slots[i].remove_child(recipe_panel)
				
				# Move recipe panel to previous slot
				slots[i - 1].add_child(recipe_panel)
				recipe_panel.position = slots[i - 1].position

func spawn_new_recipe():
	for slot in recipe_locs.get_children():
		if slot.get_child_count() == 0:
			if recipe_panel_scenes.is_empty():
				print("No recipe scenes assigned.")
				return

			var random_scene = recipe_panel_scenes[randi() % recipe_panel_scenes.size()]
			var new_recipe_panel = random_scene.instantiate()

			new_recipe_panel.position = slot.position
			slot.add_child(new_recipe_panel)

			print("Recipe spawned at slot:", slot.name)
			return
	print("All slots are full. Cannot spawn new recipe.")
