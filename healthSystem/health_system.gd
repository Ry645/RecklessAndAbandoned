extends Node

class_name HealthSystem

signal die
signal healthUpdate(health)
signal setHealthBarVars(minHealth, maxHealth, currentHealth)

@export var maxHealth:float = 100.0
@export var minHealth:float = 0.0
@export var health:float = 100.0

@export var hasGodMode:bool = false

func _ready():
	emit_signal("setHealthBarVars", minHealth, maxHealth, health)

func takeDamage(damage):
	if hasGodMode:
		return
	
	health -= damage
	#print("health: ", health)
	emit_signal("healthUpdate", health)
	emit_signal("setHealthBarVars", minHealth, maxHealth, health)
	if health <= minHealth:
		emit_signal("die")
