#TODO migrate ai : complex and annoying
#migrate ai to a component somehow
#TODO facing to player: simple
#make grunt face the player so it actually hits the player

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
@export var backpedalCircleRadius:float = 2.0
@export var maxStrafeTargetDeviation:float = 1.0

signal targetNoticed(targetBody, selfRef)
signal targetFreed(selfRef)
signal died(selfRef)

signal mouseHoveredOverMe(selfRef)

@onready var attack_interval_timer = %attackIntervalTimer
@onready var attack_startup_timer = %attackStartupTimer
@onready var mesh_instance_3d = %MeshInstance3D
@onready var hurtbox_location = %hurtboxLocation
@onready var movement_component:MovementComponent = %movementComponent
@onready var health_system = %healthSystem
#TEST add animation model for grunt to fix
@onready var attack_indicator = %attackIndicator
@onready var health_bar_position = %healthBarPosition


@export var hurtboxScene:PackedScene
@export var healthBarScene:PackedScene
#TEST notice player somehow
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
var currentAiState = aiState.NOTICE
var random
var pointToStrafeAround
var combatManager:CombatManager

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var isDead:bool = false

#TODO new feature
#SEED
# Called when the node enters the scene tree for the first time.
func _ready():
	random = randf()
	#add random sign here

#SLOW
#TODO new feature
#use nav mesh later
func _physics_process(delta):
	movement_component.applyGravity(delta)
	look_at(targetBody.position)
	rotate(Vector3(0, 1, 0), PI)
	
	match currentAiState:
		aiState.WANDER:
			#movement_component.moveTo(random spot idk)
			pass
		aiState.NOTICE:
			currentAiState = aiState.SURROUND
			emit_signal("targetNoticed", targetBody, self)
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
		aiState.TARGET:
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
			attack_indicator.visible = true
			if attack_startup_timer.is_stopped():
				attack_startup_timer.start()
		aiState.BACKPEDAL:
			attack_indicator.visible = false
			var circlePos = movement_component.get_circle_position(backpedalCircleRadius, targetBody.global_position)
			pointToStrafeAround = targetBody.global_position
			var reachedDestination:bool = movement_component.moveTo(Vector3(circlePos.x, 0, circlePos.y), backpedalSpeed)
			if reachedDestination:
				currentAiState = aiState.COMBAT
		aiState.LOSE_TARGET:
			emit_signal("targetFreed", self)
			currentAiState = aiState.SURROUND
		aiState.FORGET:
			currentAiState = aiState.WANDER
		

func target():
	currentAiState = aiState.TARGET

func takeDamage(damageVal):
	health_system.takeDamage(damageVal)

func die():
	if isDead:
		return
	
	emit_signal("died", self)
	isDead = true
	print("dead")
	queue_free()

func setHurtboxVars(hurtbox:Hurtbox):
	hurtbox.damageValue = damage
	hurtbox.hurtBoxType = 0

#TEST i honestly have no idea; investigate further on what i meant
#maybe using timers is a bad thing?
#low priority
func _on_attack_interval_timer_timeout():
	currentAiState = aiState.APPROACH

#TEST same
func _on_attack_startup_timer_timeout():
	currentAiState = aiState.BACKPEDAL
	var hurtbox = hurtboxScene.instantiate()
	setHurtboxVars(hurtbox)
	hurtbox_location.add_child(hurtbox)
	#attack_cooldown_timer.start()



func _on_mouse_entered() -> void:
	emit_signal("mouseHoveredOverMe", self)
