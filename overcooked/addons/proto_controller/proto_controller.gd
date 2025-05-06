# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D
## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"
##Name of Input Action to interact with other objects (pick up and place)
@export var input_interact = "interact"
##Name of Input Action to use action commands (such as chop or fire extinguisher)
@export var input_action = "action"
##Distance the player can interact with
@export var interact_distance : float = 2.0

##How many seconds does the player need to hold down an action
@export var required_chop_time: float = 1.0
@export var required_putout_time: float = 1.0

var current_target : Node = null
var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var held_object : Node = null
var is_interacting: bool = false
var interact_hold_time: float = 0.0

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var hold_position = $holdPosition

func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()
	
	#Interact with the closest target
	if Input.is_action_just_pressed(input_interact):
		if current_target:
			interact_with(current_target)
	


func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()
	
	#Finds the closest interactable object and adds it to current target
	find_closest_interactable()
	
	#Hold time will increase if player holding interact
	#Hold time will increase if player holding interact
	if Input.is_action_pressed(input_action):
		if current_target and current_target.is_in_group("ChoppingBoard"):
			is_interacting = true
			interact_hold_time += delta
		
			if interact_hold_time >= required_chop_time:
				current_target.chop_food()
				interact_hold_time = 0.0
				is_interacting = false
				
		elif held_object and current_target and held_object.is_in_group("FireExtinguisher"):
			is_interacting = true
			interact_hold_time += delta
			
			if interact_hold_time >= required_putout_time:
				if current_target.is_in_group("Saucepan"):
					current_target.put_out_fire()
				if current_target.has_method("get_item"):
					var item = current_target.get_item()
					if item and item.is_in_group("Saucepan"):
						item.put_out_fire()
			
	else:
		interact_hold_time = 0.0

## Will get us the closest interactable object based on interact distance
func find_closest_interactable():
	var min_distance = interact_distance
	current_target = null
	
	for obj in get_tree().get_nodes_in_group("Interactable"):
		if not obj is Node3D or (obj == held_object):
			continue
		
		##For every interactable object, will get distance between player and objects position
		var distance = global_transform.origin.distance_to(obj.global_transform.origin)
		if distance < min_distance:
			min_distance = distance
			current_target = obj

##Allows player to interact with objects based on their group
func interact_with(target: Node):
	if held_object:
		place_object(target)
		return
	else:
		if target.is_in_group("ChoppingBoard"):
			var item: Node = target.get_item()
			if item:
				target.remove_item()
				pickup_object(item)
		elif target.is_in_group("Cooker") or target.is_in_group("WorkStation"):
			var item: Node = target.get_item()
			if item:
				target.remove_item()
				pickup_object(item)
		elif target.is_in_group("Tray"):
			var item: Node = target.get_item()
			if item:
				target.remove_item()
				pickup_object(item)
			else:
				item = target.spawn_item()
				if item:
					get_tree().current_scene.add_child(item)
					pickup_object(item)
			
		else:
			print("Picking up" + target.name)
			pickup_object(target)

		
		

##Function to picks up target object
func pickup_object(obj: Node):
	if not obj.is_in_group("Pickupable"):
		print ("Can't pickup this object!")
		return
	
	held_object = obj
		
	obj.get_parent().remove_child(obj)
	hold_position.add_child(obj)
	obj.transform = Transform3D.IDENTITY #Will reset rotation/position relative to hold position
	obj.linear_velocity = Vector3.ZERO
	obj.angular_velocity = Vector3.ZERO
	var rb = obj as RigidBody3D
	rb.freeze = true
	var collision = obj.get_node("CollisionShape3D")
	collision.disabled = true
	print("Picked up" + obj.name)

##Function to place object (in a saucepan, sink, etc..)
func place_object(target: Node):
	var rb = held_object as RigidBody3D
	rb.freeze = true
	var collision = held_object.get_node("CollisionShape3D")
	collision.disabled = true
	
	#What type of object is the target?
	if target.is_in_group("Saucepan"):
		place_in_saucepan(target)
	elif target.is_in_group("ChoppingBoard") or target.is_in_group("WorkStation"):
		place_on_board(target)
	elif target.is_in_group("Cooker"):
		place_on_cooker(target)
	elif target.is_in_group("Plate"):
		place_on_plate(target)
	elif target.is_in_group("Tray"):
		place_on_tray(target)
	elif target.is_in_group("Bin"):
		place_in_bin(target)
	elif target.is_in_group("FoodConveyor"):
		if (target.place_item(held_object)):
			held_object = null
	else:
		print(target.name + " cannot be interacted with")
	
func place_in_saucepan(sauce_pan: Node):
	##Chekcs to see that the thing you try to put in the saucepan is food and is chopped
	if held_object.is_in_group("Plate"):
		var item: Node = held_object.get_item()
		if (item) and item.has_method("is_chopped") and item.is_chopped():
			if sauce_pan.add_food(item.foodType):
				held_object.remove_item()
				item.queue_free()
				item = null
				print("item removed from plate")
		if not held_object.is_full() and not sauce_pan.is_burnt():
			item = sauce_pan.return_food()
			if (item):
				held_object.place_item(item)
				sauce_pan.remove_item()
				
	elif held_object.has_method("is_chopped") and held_object.is_chopped():
		if sauce_pan.add_food(held_object.foodType):
			held_object.queue_free()
			held_object = null
	else:
		print("Can't put into saucepan")
	

func place_on_board(board: Node):
	#If board isn't full, place object on board. 
	if not board.is_full():
		if held_object:
			held_object.get_parent().remove_child(held_object)
			board.place_item(held_object)
			held_object = null
		else:
			board.return_item()
	#If it is full, check to see whether you can place item inside whatever is on board (e.g. plate, pan)
	else:
		var item: Node
		item = board.get_item()
		if item.is_in_group("Saucepan"):
			place_in_saucepan(item)
		elif item.is_in_group("Plate"):
			place_on_plate(item)

func place_on_cooker(cooker: Node):
	if not cooker.is_full():
		if held_object:
			held_object.get_parent().remove_child(held_object)
			cooker.place_item(held_object)
			held_object = null
		else:
			cooker.return_item()
	else:
		var item: Node
		item = cooker.get_item()
		if item.is_in_group("Saucepan"):
			place_in_saucepan(item)
		elif item.is_in_group("Plate"):
			place_on_plate(item)
			
			
func place_on_plate(plate: Node):
	if not plate.is_full():
		if held_object.is_in_group("Food"):
			held_object.get_parent().remove_child(held_object)
			plate.place_item(held_object)
			held_object = null
	else:
		print("Plate is full")

func place_on_tray(tray: Node):
	if not tray.is_full():
		if held_object:
			held_object.get_parent().remove_child(held_object)
			tray.place_item(held_object)
			held_object = null
		else:
			held_object = tray.get_item()
			tray.remove_item()
	else:
		var item: Node = tray.get_item()
		if item.is_in_group("Saucepan"):
			place_in_saucepan(item)
		elif item.is_in_group("Plate"):
			place_on_plate(item)
			
func place_in_bin(bin: Node):
	if held_object.is_in_group("Plate") or held_object.is_in_group("Saucepan"):
		held_object.remove_item()
	else:
		held_object.queue_free()
		held_object = null

		
		
		
		
## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false
