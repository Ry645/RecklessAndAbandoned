extends CharacterBody3D

class_name Grunt

@export var wanderSpeed:float = 3.0
@export var surroundSpeed:float = 6.0
@export var strafeSpeed:float = 1.0
@export var approachSpeed:float = 6.0
@export var backpedalSpeed:float = 6.0


@export var minSurroundCircleRadius:float = 5.0
@export var maxSurroundCircleRadius:float = 15.0
@export var stopRadius:float = 0.1

@export var gravityMultiplier:float = 1.0

#@export var steeringMagnitude:float = 2.5

#TEST
signal damagePlayer(damage)

@onready var attack_interval_timer = %attackIntervalTimer
@onready var attack_startup_timer = %attackStartupTimer
@onready var attack_cooldown_timer = %attackCooldownTimer
@onready var mesh_instance_3d = %MeshInstance3D

#TEST
@export var targetBody:Node3D

enum aiState {
	WANDER,
	NOTICE,
	SURROUND,
	STRAFE,
	TARGET,
	APPROACH,
	ATTACK,
	BACKPEDAL,
	LOSE_TARGET,
	FORGET
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
func _physics_process(_delta):
	match currentAiState:
		aiState.WANDER:
			#moveTo(random spot idk)
			pass
		aiState.SURROUND:
			var circlePos = get_circle_position(minSurroundCircleRadius)
			var reachedDestination:bool = moveTo(Vector3(circlePos.x, 0, circlePos.y), surroundSpeed)
			if reachedDestination:
				currentAiState = aiState.STRAFE
		aiState.STRAFE:
			var direction3 = global_position.direction_to(targetBody.global_position)
			var direction2 = FunctionLibrary.vec3ToVec2(direction3)
			
			mesh_instance_3d.global_rotation.y = -direction2.angle() + PI/2 #might exclude later while animating
			var directionToMove = Vector2.UP.rotated(direction2.angle())
			#print(directionToMove)
			move(directionToMove, strafeSpeed)
			
			if FunctionLibrary.vec3ToVec2(targetBody.global_position - global_position).length() >= maxSurroundCircleRadius:
				currentAiState = aiState.SURROUND
		aiState.APPROACH:
			moveTo(targetBody.global_position, surroundSpeed)
		aiState.ATTACK:
			pass
		aiState.BACKPEDAL:
			pass
	

func applyGravity(delta):
	if !is_on_floor():
		velocity.y -= gravity * delta * gravityMultiplier

func move(direction2:Vector2, speed):
	var desired_velocity2:Vector2 = direction2 * speed
	velocity.x = desired_velocity2.x
	velocity.z = desired_velocity2.y
	
	move_and_slide()

#INFO
func moveTo(targetPosition:Vector3, speed) -> bool:
	#process:
	#move to standard position
	#flatten into vec2
	#apply magnitude
	var reachedDestination:bool = false
	
	
	var raw3:Vector3 = (targetPosition - global_position) # don't normalize here
	var raw2 = Vector2(raw3.x, raw3.z)
	var direction2:Vector2 = raw2.normalized() # normalize here instead
	var desired_velocity2:Vector2 = direction2 * speed
	if raw2.length() < 1.0:
		desired_velocity2 = Vector2.ZERO
		reachedDestination = true
	velocity.x = desired_velocity2.x
	velocity.z = desired_velocity2.y
	#print(velocity)
	#move
	move_and_slide()
	
	return reachedDestination

#SEED
func get_circle_position(circleRadius:float) -> Vector2:
	var surroundCircleCenter = targetBody.global_position
	var angle = random * PI * 2;
	var xPos = surroundCircleCenter.x + cos(angle) * circleRadius;
	var yPos = surroundCircleCenter.z + sin(angle) * circleRadius;
	
	var surroundCirclePos:Vector2 = Vector2(xPos, yPos)
	return surroundCirclePos

#TEST
func _on_attack_interval_timer_timeout():
	#position.z += 1
	currentAiState = aiState.APPROACH
	attack_startup_timer.start()

#TEST
func _on_attack_startup_timer_timeout():
	#position.z += 1
	currentAiState = aiState.ATTACK
	emit_signal("damagePlayer", 20)
	attack_cooldown_timer.start()

#TEST
func _on_attack_cooldown_timer_timeout():
	currentAiState = aiState.SURROUND
	attack_interval_timer.start()
	
	
	
	#position.z -= 2
	#var randTime:float = randf_range(1, 3)
	#attack_interval_timer.wait_time = randTime
