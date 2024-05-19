extends Node

class_name MovementComponent

@export var damage:float = 20.0

@export var wanderSpeed:float = 3.0
@export var surroundSpeed:float = 6.0
@export var strafeSpeed:float = 1.0
@export var approachSpeed:float = 6.0
@export var backpedalSpeed:float = 6.0


@export var surroundCircleRadius:float = 10.0
@export var backpedalCircleRadius:float = 5.0
@export var maxStrafeTargetDeviation:float = 1.0
@export var acceptanceRadiusDefault:float = 0.1

@export var gravityMultiplier:float = 1.0

#@export var steeringMagnitude:float = 2.5

signal targetTaken
signal targetFreed

@onready var attack_interval_timer = %attackIntervalTimer
@onready var attack_startup_timer = %attackStartupTimer
@onready var mesh_instance_3d = %MeshInstance3D
@onready var hurtbox_location = %hurtboxLocation

@export var hurtboxScene:PackedScene
#TEST
@export var targetBody:Node3D

enum aiState {
	WANDER,
	NOTICE,
	SURROUND,
	STRAFE,
	TARGET,
	COMBAT,
	APPROACH,
	ATTACK,
	BACKPEDAL,
	LOSE_TARGET,
	FORGET
}

#TEST
var currentAiState = aiState.SURROUND
var random
var pointToStrafeAround

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#TODO
#SEED
# Called when the node enters the scene tree for the first time.
func _ready():
	random = randf()
	#add random sign here

#SLOW
#TODO
#use nav mesh later
func _physics_process(delta):
	applyGravity(delta)
	
	match currentAiState:
		aiState.WANDER:
			#moveTo(random spot idk)
			pass
		aiState.NOTICE:
			#moveTo(random spot idk)
			pass
		aiState.SURROUND:
			var circlePos = get_circle_position(surroundCircleRadius)
			pointToStrafeAround = targetBody.global_position
			var reachedDestination:bool = moveTo(Vector3(circlePos.x, 0, circlePos.y), surroundSpeed)
			if reachedDestination:
				currentAiState = aiState.STRAFE
		aiState.STRAFE:
			strafeAround()
			
			if FunctionLibrary.vec3ToVec2(pointToStrafeAround - targetBody.global_position).length() >= maxStrafeTargetDeviation:
				currentAiState = aiState.SURROUND
				
				
				#TEST
				#will later have grunts communicate between each other
				currentAiState = aiState.TARGET
			
			
		aiState.TARGET:
			emit_signal("targetTaken")
			currentAiState = aiState.APPROACH
		aiState.COMBAT:
			if attack_interval_timer.is_stopped():
				attack_interval_timer.start()
			strafeAround()
			if FunctionLibrary.vec3ToVec2(pointToStrafeAround - targetBody.global_position).length() >= maxStrafeTargetDeviation:
				currentAiState = aiState.BACKPEDAL
		aiState.APPROACH:
			var reachedDestination:bool = moveTo(targetBody.global_position, surroundSpeed, 2.0)
			if reachedDestination:
				currentAiState = aiState.ATTACK
		aiState.ATTACK:
			#TEST
			if attack_startup_timer.is_stopped():
				attack_startup_timer.start()
		aiState.BACKPEDAL:
			var circlePos = get_circle_position(backpedalCircleRadius)
			pointToStrafeAround = targetBody.global_position
			var reachedDestination:bool = moveTo(Vector3(circlePos.x, 0, circlePos.y), backpedalSpeed)
			if reachedDestination:
				currentAiState = aiState.COMBAT
		aiState.LOSE_TARGET:
			emit_signal("targetFreed")
			currentAiState = aiState.SURROUND
		aiState.FORGET:
			currentAiState = aiState.WANDER
		

func applyGravity(delta):
	if !is_on_floor():
		velocity.y -= gravity * delta * gravityMultiplier

func move(direction2:Vector2, speed):
	var desired_velocity2:Vector2 = direction2 * speed
	velocity.x = desired_velocity2.x
	velocity.z = desired_velocity2.y
	
	move_and_slide()

#INFO
func moveTo(targetPosition:Vector3, speed, acceptanceRadius:float = acceptanceRadiusDefault) -> bool:
	#process:
	#move to standard position
	#flatten into vec2
	#apply magnitude
	var reachedDestination:bool = false
	
	
	var raw3:Vector3 = (targetPosition - global_position) # don't normalize here
	var raw2 = Vector2(raw3.x, raw3.z)
	var direction2:Vector2 = raw2.normalized() # normalize here instead
	var desired_velocity2:Vector2 = direction2 * speed
	if raw2.length() < acceptanceRadius:
		desired_velocity2 = Vector2.ZERO
		reachedDestination = true
	velocity.x = desired_velocity2.x
	velocity.z = desired_velocity2.y
	#print(velocity)
	#move
	move_and_slide()
	
	return reachedDestination

func strafeAround():
	var direction3 = global_position.direction_to(pointToStrafeAround)
	var direction2 = FunctionLibrary.vec3ToVec2(direction3)
	
	mesh_instance_3d.global_rotation.y = -direction2.angle() + PI/2 #might exclude later while animating
	var directionToMove = Vector2.UP.rotated(direction2.angle())
	#print(directionToMove)
	move(directionToMove, strafeSpeed)

#SEED
#INFO
#used precalculus concepts for this function so that's pretty cool
func get_circle_position(circleRadius:float) -> Vector2:
	var surroundCircleCenter = targetBody.global_position
	var direction3 = targetBody.global_position.direction_to(global_position)
	var closestAngleToMove = FunctionLibrary.vec3ToVec2(direction3).angle()
	var xPos = surroundCircleCenter.x + cos(closestAngleToMove) * circleRadius;
	var yPos = surroundCircleCenter.z + sin(closestAngleToMove) * circleRadius;
	
	var surroundCirclePos:Vector2 = Vector2(xPos, yPos)
	return surroundCirclePos

func setHurtboxVars(hurtbox:Hurtbox):
	hurtbox.damageValue = damage

#TEST
func _on_attack_interval_timer_timeout():
	currentAiState = aiState.APPROACH

#TEST
func _on_attack_startup_timer_timeout():
	currentAiState = aiState.BACKPEDAL
	var hurtbox = hurtboxScene.instantiate()
	setHurtboxVars(hurtbox)
	hurtbox_location.add_child(hurtbox)
	#attack_cooldown_timer.start()

