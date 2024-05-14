extends CharacterBody3D

class_name Grunt

@export var wanderSpeed:float = 3.0
@export var surroundSpeed:float = 6.0
@export var strafeSpeed:float = 1.0
@export var engageSpeed:float = 6.0
@export var backpedalSpeed:float = 6.0

@export var surroundCircleRadius:float = 5.0
@export var stopRadius:float = 0.1

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
	STRAFE,
	ENGAGE,
	HIT,
	BACKPEDAL
}

#TEST
var currentAiState = aiState.SURROUND
var random

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#SEED
# Called when the node enters the scene tree for the first time.
func _ready():
	random = randf()

#SLOW
#TODO
#use nav mesh later
func _physics_process(delta):
	var circlePos = get_circle_position()
	#print(circlePos)
	match currentAiState:
		aiState.WANDER:
			#move(random spot idk)
			pass
		aiState.SURROUND:
			move(Vector3(circlePos.x, 0, circlePos.y), surroundSpeed, delta)
		aiState.STRAFE:
			#move()
			pass
		aiState.ENGAGE:
			move(targetBody.global_position, surroundSpeed, delta)
		aiState.HIT:
			pass
		aiState.BACKPEDAL:
			pass
		

#INFO
func move(targetPosition:Vector3, speed, delta):
	#apply gravity
	if !is_on_floor():
		velocity.y -= gravity * delta * gravityMultiplier
	
	
	#move to standard position
	var direction3:Vector3 = (targetPosition - global_position) # don't normalize here
	#flatten into vec2
	var raw2 = Vector2(direction3.x, direction3.z)
	var direction2:Vector2 = raw2.normalized() # normalize here instead
	#apply magnitude
	var desired_velocity2:Vector2 =  direction2 * speed
	##apply delta
	#var velocityToAdd = (Vector3(desired_velocity2.x, 0, desired_velocity2.y) - velocity) * delta #* steeringMagnitude
	#add to actual velocity
	if raw2.length() < 1.0:
		desired_velocity2 = Vector2.ZERO
	velocity.x = desired_velocity2.x
	velocity.z = desired_velocity2.y
	#print(velocity)
	#move
	move_and_slide()

#SEED
func get_circle_position() -> Vector2:
	var surroundCircleCenter = targetBody.global_position
	var angle = random * PI * 2;
	var xPos = surroundCircleCenter.x + cos(angle) * surroundCircleRadius;
	var yPos = surroundCircleCenter.z + sin(angle) * surroundCircleRadius;
	
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
