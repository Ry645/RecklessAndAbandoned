extends Node

class_name HealthSystem

signal die

@export var maxHealth:float = 100.0
@export var minHealth:float = 0.0
@export var health:float = 100.0

func takeDamage(damage):
	health -= damage
	print("health: ", health)
	if health <= minHealth:
		emit_signal("die")
