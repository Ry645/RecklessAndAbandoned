extends Node

class_name MovementComponent

var parentCharacter:CharacterBody3D

@export var acceptanceRadiusDefault:float = 0.1
@export var gravityMultiplier:float = 1.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	parentCharacter = get_parent()

func applyGravity(delta):
	if !parentCharacter.is_on_floor():
		parentCharacter.velocity.y -= gravity * delta * gravityMultiplier

func move(direction2:Vector2, speed):
	var desired_velocity2:Vector2 = direction2 * speed
	parentCharacter.velocity.x = desired_velocity2.x
	parentCharacter.velocity.z = desired_velocity2.y
	
	parentCharacter.move_and_slide()

#INFO
func moveTo(targetPosition:Vector3, speed, acceptanceRadius:float = acceptanceRadiusDefault) -> bool:
	#process:
	#move to standard position
	#flatten into vec2
	#apply magnitude
	var reachedDestination:bool = false
	
	
	var raw3:Vector3 = (targetPosition - parentCharacter.global_position) # don't normalize here
	var raw2 = Vector2(raw3.x, raw3.z)
	var direction2:Vector2 = raw2.normalized() # normalize here instead
	var desired_velocity2:Vector2 = direction2 * speed
	if raw2.length() < acceptanceRadius:
		desired_velocity2 = Vector2.ZERO
		reachedDestination = true
	parentCharacter.velocity.x = desired_velocity2.x
	parentCharacter.velocity.z = desired_velocity2.y
	#print(velocity)
	#move
	parentCharacter.move_and_slide()
	
	return reachedDestination

func strafeAround(pointToStrafeAround, strafeSpeed):
	var direction3 = pointToStrafeAround.global_position.direction_to(pointToStrafeAround)
	var direction2 = FunctionLibrary.vec3ToVec2(direction3)
	var directionToMove = Vector2.UP.rotated(direction2.angle())
	#print(directionToMove)
	move(directionToMove, strafeSpeed)

#SEED
#INFO
#used precalculus concepts for this function so that's pretty cool
func get_circle_position(circleRadius:float, targetPosition) -> Vector2:
	var surroundCircleCenter = targetPosition
	var direction3 = targetPosition.direction_to(parentCharacter.global_position)
	var closestAngleToMove = FunctionLibrary.vec3ToVec2(direction3).angle()
	var xPos = surroundCircleCenter.x + cos(closestAngleToMove) * circleRadius;
	var yPos = surroundCircleCenter.z + sin(closestAngleToMove) * circleRadius;
	
	var surroundCirclePos:Vector2 = Vector2(xPos, yPos)
	return surroundCirclePos
