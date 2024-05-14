extends CharacterBody3D

class_name Grunt

@export var wanderSpeed:float = 3.0
@export var surroundSpeed:float = 1.0
@export var engageSpeed:float = 6.0
@export var backpedalSpeed:float = 6.0

@export var surroundCircleRadius:float = 10.0

#@export var steeringMagnitude:float = 2.5

#TEST
signal damagePlayer(damage)

@onready var attack_interval_timer = %attackIntervalTimer
@onready var attack_startup_timer = %attackStartupTimer
@onready var attack_cooldown_timer = %attackCooldownTimer

#TEST
@export var targetBody:Node3D

enum attackState {
	WANDER,
	SURROUND,
	ENGAGE,
	HIT,
	BACKPEDAL
}

#									TEST
var currentAttackState = attackState.SURROUND

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	move(Vector3.ZERO, wanderSpeed, delta)
	match currentAttackState:
		attackState.WANDER:
			#move()
			pass

#INFO
func move(targetPosition:Vector3, speed, delta):
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
	velocity = Vector3(desired_velocity2.x, 0, desired_velocity2.y)
	print(velocity)
	#move
	move_and_slide()



func _on_attack_interval_timer_timeout():
	position.z += 1
	attack_startup_timer.start()


func _on_attack_startup_timer_timeout():
	position.z += 1
	#TEST
	emit_signal("damagePlayer", 20)
	attack_cooldown_timer.start()


func _on_attack_cooldown_timer_timeout():
	position.z -= 2
	#var randTime:float = randf_range(1, 3)
	#attack_interval_timer.wait_time = randTime
	attack_interval_timer.start()
