extends Node3D

signal damagePlayer(damage)

@onready var attack_interval_timer = %attackIntervalTimer
@onready var attack_startup_timer = %attackStartupTimer
@onready var attack_cooldown_timer = %attackCooldownTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_attack_interval_timer_timeout():
	position.z += 1
	attack_startup_timer.start()


func _on_attack_startup_timer_timeout():
	position.z += 1
	emit_signal("damagePlayer", 20)
	attack_cooldown_timer.start()


func _on_attack_cooldown_timer_timeout():
	position.z -= 2
	#var randTime:float = randf_range(1, 3)
	#attack_interval_timer.wait_time = randTime
	attack_interval_timer.start()
