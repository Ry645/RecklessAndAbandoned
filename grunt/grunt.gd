extends CharacterBody3D

class_name Grunt

@export var wanderSpeed:float = 3.0
@export var surroundSpeed:float = 6.0
@export var strafeSpeed:float = 1.0
@export var engageSpeed:float = 6.0
@export var backpedalSpeed:float = 6.0

@export var surroundCircleRadius:float = 5.0
@export var acceptanceRadius:float = 0.5
@export var angularVelocity:float = 0.25
var angleSign:int = 1

@export var gravityMultiplier:float = 1.0

#@export var steeringMagnitude:float = 2.5

#TEST
signal damagePlayer(damage)

@onready var attack_interval_timer = %attackIntervalTimer
@onready var attack_startup_timer = %attackStartupTimer
@onready var attack_cooldown_timer = %attackCooldownTimer

#TEST
@export var targetBody:Node3D

enum aiState {
	WANDER,
	SURROUND,
	#STRAFE, # don't need it since surround can have strafe movement
	ENGAGE,
	HIT,
	BACKPEDAL
}

#TEST
var currentAiState = aiState.SURROUND
var random
var angleOffset:float # to circle strafe around player
var previousDirection:Vector2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#SEED
# Called when the node enters the scene tree for the first time.
func _ready():
	random = randf()
	if randf() > 0.5:
		angleSign *= -1

#SLOW
#TODO
#use nav mesh later
func _physics_process(delta):
	applyGravity(delta)
	
	var circlePos = get_circle_position(delta)
	#print(circlePos)
	match currentAiState:
		aiState.WANDER:
			#move(random spot idk)
			pass
		aiState.SURROUND:
			move(Vector3(circlePos.x, 0, circlePos.y), surroundSpeed, delta)
			#move(Vector3(circlePos.x, 0, circlePos.y), strafeSpeed, delta)
		aiState.ENGAGE:
			move(targetBody.global_position, surroundSpeed, delta)
		aiState.HIT:
			pass
		aiState.BACKPEDAL:
			pass
	

func applyGravity(delta):
	if !is_on_floor():
		velocity.y -= gravity * delta * gravityMultiplier

#INFO
func move(targetPosition:Vector3, speed, delta):
	#move to standard position
	#flatten into vec2
	#apply magnitude
	
	var direction3:Vector3 = (targetPosition - global_position) # don't normalize here
	var raw2 = Vector2(direction3.x, direction3.z)
	var direction2:Vector2 = raw2.normalized() # normalize here instead
	var desired_velocity2:Vector2 =  direction2 * speed
	
	if raw2.length() < acceptanceRadius:
		desired_velocity2 = Vector2.ZERO
	
	#add to actual velocity
	velocity.x = desired_velocity2.x
	velocity.z = desired_velocity2.y
	
	print(velocity)
	#move
	move_and_slide()

#SEED
func get_circle_position(delta) -> Vector2:
	var surroundCircleCenter = targetBody.global_position
	var angle = random * PI * 2 + angleOffset
	angleOffset += angularVelocity * delta * angleSign
	
	var xPos = surroundCircleRadius * cos(angle) + surroundCircleCenter.x
	var yPos = surroundCircleRadius * sin(angle) + surroundCircleCenter.z
	
	var surroundCirclePos:Vector2 = Vector2(xPos, yPos)
	return surroundCirclePos

#TEST
func _on_attack_interval_timer_timeout():
	#position.z += 1
	currentAiState = aiState.ENGAGE
	attack_startup_timer.start()

#TEST
func _on_attack_startup_timer_timeout():
	#position.z += 1
	currentAiState = aiState.HIT
	emit_signal("damagePlayer", 20)
	attack_cooldown_timer.start()

#TEST
func _on_attack_cooldown_timer_timeout():
	currentAiState = aiState.SURROUND
	attack_interval_timer.start()
	
	
	
	#position.z -= 2
	#var randTime:float = randf_range(1, 3)
	#attack_interval_timer.wait_time = randTime
