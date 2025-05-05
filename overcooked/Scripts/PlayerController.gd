extends CharacterBody3D
"""

Written by Jordan Pryor TSE 24/25

Integrated by .....     TSE 24/25

File Order:
	Variables: (52 - 145)
		Model
		Player Config
		Movement
		Holding
		Animation
		Debug
		input
	Helper Functions: (149 - 190)
		_ready()
		_apply_dead_zone
		get_player_controller
		get_player_button
		input_cooldown
		start_dash
		end_dash
	Process:
		Checks
		Controller Input
		Change Mesh
		Dash
		Hold/Drop
		Movement
		
	Movment Helpers:
		handleRotation()
	Animation:
		HandleAnimation()
		UpdateTree()
	Dash Particles:
		emitParticles()
	Pickup/Drop:
		pickupObject()
		dropObject()
	Sway:
		updateSway()
	CycleMeshes:
		cycleMeshes()
		reverseCycleMeshes()

"""

# --------------------- MODEL ---------------------
@export_category("Character Meshes")
@export_subgroup("Body Mesh")
@export var body_meshes: Array[Mesh] = []
@export_subgroup("Head Mesh")
@export var head_meshes: Array[Mesh] = []
@export var body_mesh: MeshInstance3D  # Drag the body mesh node here in the Inspector
@export var head_mesh: MeshInstance3D  # Drag the head mesh node here in the Inspector


var last_input_axis := 0.0
@export var mesh_cycle_cooldown := 0.3  # Seconds between cycles
var last_mesh_cycle_time := 0.0
var body_mesh_index = 0
var head_mesh_index = 0

# --------------------- PLAYER CONFIG --------------------
@export_category("PLAYER ID")
@export var playerID: int = 1
var player1Contr = 0
var player2Contr = 1

@export_category("Player 1 Controller Mapping")
@export_subgroup("Movement Controls")
@export var player1_dash_button := JOY_BUTTON_RIGHT_SHOULDER
@export var player1_hold_button := JOY_BUTTON_LEFT_SHOULDER
@export var player1_cycle_mesh_right := JOY_BUTTON_DPAD_RIGHT  
@export var player1_cycle_mesh_left := JOY_BUTTON_DPAD_LEFT 
@export_subgroup("Emotes")
@export var player1_emote_1_button := JOY_BUTTON_DPAD_DOWN
@export var player1_emote_2_button := JOY_BUTTON_DPAD_UP

@export_category("Player 2 Controller Mapping")
@export_subgroup("Movement")
@export var player2_dash_button := JOY_BUTTON_RIGHT_SHOULDER
@export var player2_hold_button := JOY_BUTTON_LEFT_SHOULDER
@export var player2_cycle_mesh_right := JOY_BUTTON_DPAD_RIGHT  
@export var player2_cycle_mesh_left := JOY_BUTTON_DPAD_LEFT
@export_subgroup("Emote Controls")
@export var player2_emote_1_button := JOY_BUTTON_DPAD_DOWN
@export var player2_emote_2_button := JOY_BUTTON_DPAD_UP


# --------------------- MOVEMENT ---------------------
@export_category("Physics")
@export_subgroup("PlayerVariables")
<<<<<<< Updated upstream
@export var speed := 3.0
=======
@export var speed := -3.0
>>>>>>> Stashed changes
@export var dashSpeed := 10.0
@export var dashDuration := 0.15
@export var dashCooldown := 0.5
@export var gravity := 0.1
@export var friction := 0.15
@export var rotationSpeed := 10.0
@export var deadZone := 0.1 

var inputVector = Vector3.ZERO
var isDashing = false
var dashTimer = 0.0
var dashCooldownTimer = 0.0
var timer = 0.0

# --------------------- HOLDING ---------------------
@export_category("Holding")
var heldObject: RigidBody3D = null
var original_collision_mask := 0
var isHolding = false
@onready var holdPoint = $ItemPosition
@export var sway_amount := 0.05
@export var sway_speed := 3.0
var sway_time := 0.0

# --------------------- ANIMATION ---------------------
@export_category("Animation")
enum { IDLE, RUN, HOLD, DASH }
var currentAnim = IDLE
var walkValue = 0.0
var holdValue = 0.0
var dashValue = 0.0
@export var blendSpeed := 15.0
var isEmoting = false

@onready var animationPlayer = $CharModel/AnimationPlayer
@onready var animationTree = $CharModel/AnimationPlayer/AnimationTree
@onready var particleSystem = $"CharModel/character-male-d/Skeleton3D/body-mesh/DashParticles"

# --------------------- DEBUG ---------------------
@export_category("Raycast")
@export var raycastLength := 2.0
@export var raycastHeight := 0.1

# --------------------- INPUT ---------------------
var inputDELAY = 0.2
var lastHoldInput = -inputDELAY
var lastDashInput = -inputDELAY
var lastMeshInput = -inputDELAY

# --------------------- HELPER FUNCTIONS ---------------------

func _ready():
	floor_stop_on_slope = true
	floor_max_angle = deg_to_rad(45)

func _apply_dead_zone(input_value: float) -> float:
	return input_value if abs(input_value) >= deadZone else 0

func get_player_controller() -> int:
	return player1Contr if playerID == 1 else player2Contr

func get_player_button(button_type: String) -> int:
	if button_type == "dash":
		return player1_dash_button if playerID == 1 else player2_dash_button
	elif button_type == "hold":
		return player1_hold_button if playerID == 1 else player2_hold_button
	elif button_type == "cycle_mesh_right":
		return player1_cycle_mesh_right if playerID == 1 else player2_cycle_mesh_right
	elif button_type == "cycle_mesh_left":
		return player1_cycle_mesh_left if playerID == 1 else player2_cycle_mesh_left
	return -1
	
func input_cooldown(lastInput: float) -> bool:
	return timer - lastInput > inputDELAY

func start_dash():
	isDashing = true
	dashTimer = dashDuration
	dashCooldownTimer = dashCooldown
	currentAnim = DASH
	emitParticles(inputVector)
	lastDashInput = timer
	particleSystem.emitting = true

func end_dash():
	isDashing = false
	particleSystem.emitting = false
	# Smoothly transition back to normal animation
	if isHolding:
		currentAnim = HOLD
	else:
		currentAnim = RUN if inputVector.length() > 0.1 else IDLE

# --------------------- PROCESS ---------------------
func _physics_process(delta):
	#Checks 
	timer += delta
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0 
	if isEmoting:
		return
	if dashCooldownTimer > 0:
		dashCooldownTimer -= delta

	# Controller Input
	var controller = get_player_controller()
	inputVector = Vector3(
		_apply_dead_zone(Input.get_joy_axis(controller, 0)),
		0,
		_apply_dead_zone(Input.get_joy_axis(controller, 1))
	).normalized()
	
	#Change Mesh
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_mesh_cycle_time >= mesh_cycle_cooldown:    
		if Input.is_joy_button_pressed(controller, get_player_button("cycle_mesh_right")):
			cycleMeshes()
			last_mesh_cycle_time = current_time
		elif Input.is_joy_button_pressed(controller, get_player_button("cycle_mesh_left")):
			reverseCycleMeshes()
			last_mesh_cycle_time = current_time

	# Dashing
	if input_cooldown(lastDashInput) and Input.is_joy_button_pressed(get_player_controller(), get_player_button("dash")):
		if not isDashing and dashCooldownTimer <= 0:  # Only dash if not already dashing and cooldown is ready
			start_dash()

	if isDashing:
		dashTimer -= delta
		if dashTimer <= 0:
			end_dash()
	
	# Holding (pickup/drop object) with input cooldown
	if input_cooldown(lastHoldInput) and Input.is_joy_button_pressed(get_player_controller(), get_player_button("hold")) and not isEmoting:
		lastHoldInput = timer  # Update the time of the last hold input
		if heldObject:
			dropObject()
		else:
			pickupObject()

	# Movement
	var currentSpeed = dashSpeed if isDashing else speed
	velocity = velocity.lerp(inputVector * currentSpeed, 0.1 if inputVector.length() > 0 else friction)
	velocity.y = 0  
	
	move_and_slide()

	handleRotation(inputVector, delta)
	handleAnimations(delta, inputVector)

	if heldObject:
		updateSway(delta)

# --------------------- MOVEMENT HELPERS ---------------------
func handleRotation(inputDirection: Vector3, delta: float):
	if inputDirection.length() > 0.1:
		var targetAngle = atan2(inputDirection.x, inputDirection.z)
		rotation.y = lerp_angle(rotation.y, targetAngle, rotationSpeed * delta)

# --------------------- ANIMATIONS ---------------------
func handleAnimations(delta, inputVector):
	currentAnim = HOLD if isHolding else (RUN if inputVector.length() > 0.1 else IDLE)

	match currentAnim:
		IDLE:
			walkValue = lerpf(walkValue, 0, blendSpeed * delta)
			holdValue = lerpf(holdValue, 0, blendSpeed * delta)
			dashValue = lerpf(dashValue, 0, blendSpeed * delta)
		RUN:
			walkValue = lerpf(walkValue, 1, blendSpeed * delta)
			holdValue = lerpf(holdValue, 0, blendSpeed * delta)
			dashValue = lerpf(dashValue, 0, blendSpeed * delta)
		HOLD:
			walkValue = lerpf(walkValue, 0.75, blendSpeed * delta)
			holdValue = lerpf(holdValue, 1.0, blendSpeed * delta)
			dashValue = lerpf(dashValue, 0, blendSpeed * delta)
		DASH:
			walkValue = lerpf(walkValue, 0.75, blendSpeed * delta)
			holdValue = lerpf(holdValue, 0, blendSpeed * delta)
			dashValue = lerpf(dashValue, 2, 2 * delta)

	UpdateTree()

func UpdateTree():
	animationTree.set("parameters/Move/blend_amount", walkValue)
	animationTree.set("parameters/MoveHold/add_amount", holdValue)
	animationTree.set("parameters/Dash/blend_amount", dashValue)

# --------------------- DASH PARTICLES ---------------------
func emitParticles(dashDirection: Vector3):
	if dashDirection.length() < 0.1:
		dashDirection = -global_transform.basis.z

	var gravityV = -dashDirection.normalized() * 15
	particleSystem.process_material.set("gravity", gravityV)
	particleSystem.restart()

# --------------------- PICKUP/DROP ---------------------
func pickupObject():
	var from = global_transform.origin + Vector3(0, raycastHeight, 0)
	var to = from + global_transform.basis.z * raycastLength
	var rayParams = PhysicsRayQueryParameters3D.new()
	rayParams.from = from
	rayParams.to = to
	rayParams.exclude = [self]
	rayParams.collision_mask = 0b1
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
	var result = get_world_3d().direct_space_state.intersect_ray(rayParams)
	if result and result.collider is RigidBody3D:
		isHolding = true
		heldObject = result.collider
		original_collision_mask = heldObject.collision_mask

		heldObject.collision_layer = 0
		heldObject.collision_mask = 0
		heldObject.set_physics_process(false)
		heldObject.freeze = true
		heldObject.set_freeze_mode(RigidBody3D.FREEZE_MODE_STATIC)
		heldObject.gravity_scale = 0
		heldObject.continuous_cd = false
		heldObject.linear_velocity = Vector3.ZERO
		heldObject.angular_velocity = Vector3.ZERO

		if heldObject.get_parent():
			heldObject.get_parent().remove_child(heldObject)
		holdPoint.add_child(heldObject)
		heldObject.global_transform = holdPoint.global_transform
		heldObject.rotation = Vector3.ZERO

func dropObject():
	if heldObject:
		heldObject.collision_layer = 1
		heldObject.collision_mask = original_collision_mask
		heldObject.set_physics_process(true)
		heldObject.freeze = false
		heldObject.gravity_scale = 1.0

		heldObject.get_parent().remove_child(heldObject)
		get_tree().root.add_child(heldObject)
		heldObject.global_transform = holdPoint.global_transform
		heldObject.linear_velocity = -global_transform.basis.z * 2.0

		isHolding = false
		heldObject = null

# --------------------- HOLD SWAY ---------------------
func updateSway(delta):
	sway_time += delta * sway_speed
	var sway_offset = Vector3(0, sin(sway_time) * sway_amount * 2, 0)
	var target_position = holdPoint.global_transform.origin + sway_offset
	heldObject.global_transform.origin = lerp(heldObject.global_transform.origin, target_position, 10.0 * delta)
 
# --------------------- CYCLE MESHES ---------------------
func cycleMeshes():
	body_mesh_index = (body_mesh_index + 1) % body_meshes.size()
	body_mesh.mesh = body_meshes[body_mesh_index]
	
	head_mesh_index = (head_mesh_index + 1) % head_meshes.size()
	head_mesh.mesh = head_meshes[head_mesh_index]

func reverseCycleMeshes():
	# Only cycle meshes for this player
	body_mesh_index = (body_mesh_index - 1 + body_meshes.size()) % body_meshes.size()
	body_mesh.mesh = body_meshes[body_mesh_index]
	
	head_mesh_index = (head_mesh_index - 1 + head_meshes.size()) % head_meshes.size()
	head_mesh.mesh = head_meshes[head_mesh_index]
