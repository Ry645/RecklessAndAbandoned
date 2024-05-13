extends CharacterBody3D

class_name Player

@export var SPEED:float = 3.0
@export var SPRINT_FACTOR:float = 2.0
@export var JUMP_VELOCITY:float = 4.5
@export var gravityMultiplier:float = 1.0
@export var turnSpeed:float = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#  :=  symbol means I KNOW WHAT TYPE THIS VAR IS instead of eh its whatever
@onready var h := %h
@onready var v := %v
@onready var camera:Camera3D = %Camera3D
@onready var pickup_ray = %pickupRay
@onready var inventory = %inventory
@onready var mesh = %mesh

var b_cameraLock:bool = false

func _unhandled_input(event):
	# if not tabbed out (ie playing game)
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# if tabbed out (ie alt tab but in this case esc)  AND IT DOES DISABLE CAMERA MOVEMENT LATER IN THE CODE
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: # RIGHT HERE
		if event is InputEventMouseMotion:
			#relative is new mouse pos compared to old mouse pos
			#negative sign used for making feel more natural
			#also rotate_y means rotating along the y-axis
			#small number multiply b/c radians
			h.rotate_y(-event.relative.x * 0.00125)
			if b_cameraLock:
				mesh.rotate_y(-event.relative.x * 0.00125)
			v.rotate_x(-event.relative.y * 0.00125)
			#neck separate from pivot point to account for moving forward and right without flying into the stratosphere
	
	v.rotation.x = clamp(v.rotation.x, -PI/2+0.0000001, PI/2-0.0000001)


func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta * gravityMultiplier

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	# vector3(left/right, up/down but unused, forward/backward)
	# basis = orientation or perspective direction
	var direction = (h.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # So earlier i used neck.transform.basis, and while it sounded right, it was actually getting the RELATIVE direction of the neck, which is always 0.
	#Instead I should use neck.global_basis to get the true global direction.
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		turnPlayerTowardsMovement(direction, delta)
	else:
		#used to stop player
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	inputProcess()
	
	move_and_slide()





func inputProcess(): # to be called in physics process
	
	if Input.is_action_just_pressed("sprint"):
		SPEED *= SPRINT_FACTOR
	
	if Input.is_action_just_released("sprint"):
		SPEED /= SPRINT_FACTOR
	
	if Input.is_action_just_pressed("pickup"):
		pickItemForInventory()
	
	if Input.is_action_just_pressed("cameraLock"):
		toggleCameraLock()

#to be used with camera lock
func toggleCameraLock():
	if !b_cameraLock: # free to lock
		b_cameraLock = true
		#snap player direction to camera direction
		mesh.rotation.y = h.rotation.y + PI
		
	else:
		b_cameraLock = false

func turnPlayerTowardsMovement(direction:Vector3, delta):
	if !b_cameraLock:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(direction.x, direction.z), delta * turnSpeed)
	else:
		pass

func pickItemForInventory():
	var itemRes = pickup_ray.pickup()
	inventory.addToInventory(itemRes)
