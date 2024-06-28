extends CharacterBody3D

class_name Player

#TODO better first person culling : complex
#make player disappear like in botw so first person looks better
#TODO migrate to hitbox node : simple
#migrate hit testing to new hitbox node; redirection function in player script

var animationsToTravelTo:Array

#TODO migrate anim class : annoying
#migrate to a separate class
#actually migrate all of this animation logic to an animation component that connects to the animation tree
var dictPossibleAnimationDestinations = {
	#blockState
	#TODO have lower swing for each in place of holdSwordArm: new feature
	"holdSwordArm" = ["raiseQuickBlock", "swing"],
	"lowerQuickBlock" = ["raiseQuickBlock"],
	"raiseQuickBlock" = ["lowerQuickBlock", "parry1"],
	"parry1" = ["holdSwordArm", "parry2"],
	"parry2" = ["holdSwordArm", "parry3"],
	"parry3" = ["holdSwordArm", "parry2"],
	
	"swing" = ["swing_001", "holdSwordArm"],
	"swing_001" = ["swing_002", "holdSwordArm"],
	"swing_002" = ["swing_001", "holdSwordArm"],
	
	#legState
	"rest" = "walkAnimation",
	"walkAnimation" = "rest",
}

var dictParryProcess = {
	"raiseQuickBlock" = "parry1",
	"parry1" = "parry2",
	"parry2" = "parry3",
	"parry3" = "parry2",
}
var dictAttackProcess = {
	"holdSwordArm" = "swing",
	"swing" = "swing_001",
	"swing_001" = "swing_002",
	"swing_002" = "swing_001",
}
var dictLowerSwordProcess = {
	"raiseQuickBlock" = "lowerQuickBlock",
}

signal setHealthBarVars(minHealth, maxHealth, currentHealth)
signal healthUpdate(health)

@export var SPEED:float = 6.0
@export var DASH_FACTOR:float = 3.0
@export var JUMP_VELOCITY:float = 4.5
@export var gravityMultiplier:float = 1.0
@export var turnSpeed:float = 10.0

@export var attackInterval:float = 0.3

var b_cameraLock:bool = false
var canTeleportSmash:bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var hurtboxScene:PackedScene

#  :=  symbol means I KNOW WHAT TYPE THIS VAR IS instead of eh its whatever
#maybe just use actual type hinting such as h:Node3D or player:Player
@onready var h := %h
@onready var v := %v
@onready var camera:Camera3D = %Camera3D
@onready var pickup_ray = %pickupRay
@onready var inventory = %inventory
@onready var mesh = %mesh1
@onready var animationTree:AnimationTree = %AnimationTree
@onready var blocking_system:BlockingSystem = %blockingSystem
@onready var health_system:HealthSystem = %healthSystem
@onready var sword:Node3D = %sword
@onready var lock_on_system:LockOnSystem = %lockOnSystem
@onready var attack_cooldown:Timer = %attackCooldown


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
	# basis = rotation (and scale but that doesn't matter)
	var direction:Vector3 = (h.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # So earlier i used neck.transform.basis, and while it sounded right, it was actually getting the RELATIVE direction of the neck, which is always 0.
	#Instead I should use neck.global_basis to get the true global direction.
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		appendAnimation("parameters/legState/playback", "walkAnimation")
		turnPlayerTowardsMovement(direction, delta)
	
	else:
		#used to stop player
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		appendAnimation("parameters/legState/playback", "rest")
	
	inputProcess()
	
	move_and_slide()
	
	updateAnimations()


func appendAnimation(parameterPath, stateToTravel:String):
	animationsToTravelTo.append([parameterPath, stateToTravel])

func updateAnimations():
	for animation in animationsToTravelTo:
		var animationPlayback:AnimationNodeStateMachinePlayback = animationTree.get(animation[0])
		
		match animation[1]:
			#custom animation
			"parry":
				if animationPlayback.get_current_node() in dictParryProcess:
					animation[1] = dictParryProcess[animationPlayback.get_current_node()] #get current to play next
			"attack":
				if animationPlayback.get_current_node() in dictAttackProcess:
					animation[1] = dictAttackProcess[animationPlayback.get_current_node()]
			"lowerSword":
				if animationPlayback.get_current_node() in dictLowerSwordProcess:
					animation[1] = dictLowerSwordProcess[animationPlayback.get_current_node()]
				else:
					#HACK will later just add in new animations to cover holdSwordArm
					animation[1] = "holdSwordArm"
		
		# get current animation, and all possible nodes to travel to using a dictionary
		# if you travel to a animation, then it checks to see if it's even possible using the dictionary
		# if not, stop, if yes, start new animation
		
		if animationPlayback.get_current_node() && animation[1] in dictPossibleAnimationDestinations[animationPlayback.get_current_node()]:
			animationPlayback.travel(animation[1])
		
	
	animationsToTravelTo.clear()

func inputProcess(): # to be called in physics process
	if Input.is_action_just_pressed("pickup"):
		pickItemForInventory()
	
	if Input.is_action_just_pressed("cameraLock"):
		toggleCameraLock()
	
	if Input.is_action_just_pressed("block"):
		blocking_system.startBlock()
	
	if Input.is_action_just_released("block"):
		blocking_system.endBlock()
	
	if Input.is_action_just_pressed("skill1"):
		teleportSmash(lock_on_system.lockedEnemy)
		#change this to config with lockOn system
	
	if Input.is_action_pressed("attack"):
		if attack_cooldown.is_stopped():
			swingShovel()
			attack_cooldown.start(attackInterval)
	
	if Input.is_action_just_pressed("lockOn"):
		lock_on_system.readyLockOn()
	
	if Input.is_action_just_released("lockOn"):
		lock_on_system.tryLockOn()

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

#TODO change teleport slam to attack dash that snaps onto enemies : new feature fun
#TODO will also have a skill bar : new feature complex
func teleportSmash(target):
	if canTeleportSmash:
		if target == null:
			target = self
		canTeleportSmash = false
		print("FUSTO")
		await get_tree().create_timer(0.75).timeout
		position = target.position
		print("RAA")
		await get_tree().create_timer(1.0).timeout
		canTeleportSmash = true

#TEST
func swingShovel():
	var hurtbox = hurtboxScene.instantiate() as Hurtbox
	hurtbox.setVars("playerSword")
	add_child(hurtbox)
	$lowerSwordTimer.start()
	appendAnimation("parameters/armState/playback", "attack")

func playerDeath():
	print("die")

func takeDamage(damage):
	blocking_system.takeDamage(damage)

func _on_blocking_system_attack_parried():
	appendAnimation("parameters/armState/playback", "parry")
	$lowerSwordTimer.start()


func _on_blocking_system_block_started():
	appendAnimation("parameters/armState/playback", "raiseQuickBlock")


func _on_blocking_system_block_ended():
	appendAnimation("parameters/armState/playback", "lowerQuickBlock")


func _on_blocking_system_parry_window_ended():
	$lowerSwordTimer.start()

#TEST
func _on_grunt_damage_player(damage):
	takeDamage(damage)


func _on_health_system_health_update(health):
	emit_signal("healthUpdate", health)


func _on_health_system_set_health_bar_vars(minHealth, maxHealth, currentHealth):
	emit_signal("setHealthBarVars", minHealth, maxHealth, currentHealth)


func _on_lower_sword_timer_timeout():
	appendAnimation("parameters/armState/playback", "lowerSword")
