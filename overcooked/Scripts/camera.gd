extends Camera3D

@export var target_path: NodePath  # Player 1
@export var target_path2: NodePath  # Player 2
@export var follow_offset := Vector3(0, 3, 2.5)
@export var follow_smoothness := 5.0

var target1: Node3D
var target2: Node3D

func _ready():
	if target_path:
		target1 = get_node(target_path)
	else:
		push_warning("No target_path set for camera follow Player 1!")

	if target_path2:
		target2 = get_node(target_path2)
	else:
		push_warning("No target_path2 set for camera follow Player 2!")

	# Lock in fixed rotation (angled downward, not based on players)
	rotation_degrees = Vector3(-45, 180, 0)  # Set once and never again

func _physics_process(delta):
	if not target1 or not target2:
		return

	# Calculate Manhattan distance between Player 1 and Player 2
	var manhattan_distance = Vector3(
		abs(target1.global_transform.origin.x - target2.global_transform.origin.x),
		abs(target1.global_transform.origin.y - target2.global_transform.origin.y),
		abs(target1.global_transform.origin.z - target2.global_transform.origin.z)
	)

	# Find the midpoint between Player 1 and Player 2 (for the camera to follow)
	var midpoint = (target1.global_transform.origin + target2.global_transform.origin) / 2
	
	# Adjust the camera's position based on the Manhattan distance, adding an offset
	var desired_position = midpoint + follow_offset + manhattan_distance / 4.0  # You can tweak the factor to your liking
	
	# Move the camera smoothly towards the desired position
	global_transform.origin = global_transform.origin.lerp(desired_position, delta * follow_smoothness)
