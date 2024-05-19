#TODO
#migrate ai to a component somehow

extends CharacterBody3D

class_name Grunt

@export var damage:float = 20.0

@export var wanderSpeed:float = 3.0
@export var surroundSpeed:float = 6.0
@export var strafeSpeed:float = 1.0
@export var combatSpeed:float = 1.5
@export var approachSpeed:float = 6.0
@export var backpedalSpeed:float = 6.0


@export var surroundCircleRadius:float = 10.0
@export var backpedalCircleRadius:float = 5.0
@export var maxStrafeTargetDeviation:float = 1.0

#@export var steeringMagnitude:float = 2.5

signal targetTaken
signal targetFreed

@onready var attack_interval_timer = %attackIntervalTimer
@onready var attack_startup_timer = %attackStartupTimer
@onready var mesh_instance_3d = %MeshInstance3D
@onready var hurtbox_location = %hurtboxLocation
@onready var movement_component:MovementComponent = %movementComponent

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
var combatManager:CombatManager

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
	movement_component.applyGravity(delta)
	
	match currentAiState:
		aiState.WANDER:
			#movement_component.moveTo(random spot idk)
			pass
		aiState.NOTICE:
			#notice player or target somehow idk
			pass
		aiState.SURROUND:
			var circlePos = movement_component.get_circle_position(surroundCircleRadius, targetBody.global_position)
			pointToStrafeAround = targetBody.global_position
			var reachedDestination:bool = movement_component.moveTo(Vector3(circlePos.x, 0, circlePos.y), surroundSpeed)
			if reachedDestination:
				currentAiState = aiState.STRAFE
		aiState.STRAFE:
			movement_component.strafeAround(pointToStrafeAround, strafeSpeed)
			
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
			movement_component.strafeAround(pointToStrafeAround, combatSpeed)
			if FunctionLibrary.vec3ToVec2(pointToStrafeAround - targetBody.global_position).length() >= maxStrafeTargetDeviation:
				currentAiState = aiState.BACKPEDAL
		aiState.APPROACH:
			var reachedDestination:bool = movement_component.moveTo(targetBody.global_position, surroundSpeed, 2.0)
			if reachedDestination:
				currentAiState = aiState.ATTACK
		aiState.ATTACK:
			#TEST
			if attack_startup_timer.is_stopped():
				attack_startup_timer.start()
		aiState.BACKPEDAL:
			var circlePos = movement_component.get_circle_position(backpedalCircleRadius, targetBody.global_position)
			pointToStrafeAround = targetBody.global_position
			var reachedDestination:bool = movement_component.moveTo(Vector3(circlePos.x, 0, circlePos.y), backpedalSpeed)
			if reachedDestination:
				currentAiState = aiState.COMBAT
		aiState.LOSE_TARGET:
			emit_signal("targetFreed")
			currentAiState = aiState.SURROUND
		aiState.FORGET:
			currentAiState = aiState.WANDER
		

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

