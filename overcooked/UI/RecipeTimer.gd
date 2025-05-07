extends Node

@export var panel: Panel

var timer_duration := 50.0
var elapsed_time := 0.0
var original_size := Vector2()
var is_finished := false

func _ready():
	# Store original panel size
	if panel:
		original_size = panel.size
	else:
		push_warning("Panel reference is not assigned!")

func _process(delta):
	if is_finished or panel == null:
		return

	# Timer logic
	elapsed_time += delta
	if elapsed_time >= timer_duration:
		_finish()
	else:
		# Shrink the panel width to indicate progress
		var progress := elapsed_time / timer_duration
		panel.size.x = original_size.x * (1.0 - progress)

func finish_Recipe():
	# External call to finish the recipe early
	if not is_finished:
		_finish()

func _finish():
	is_finished = true
	print_debug("Recipe Finished")

	# Ensure the panel is still valid before removing
	if is_instance_valid(panel):
		print_debug("Recipe Deleted")
		panel.get_parent().queue_free()
		panel = null  # Clear reference to avoid future use
