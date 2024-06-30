extends Node

class_name StaminaSystem

@export var stamina:float = 3
@export var minStamina:float = 0
@export var maxStamina:float = 3

@export var regenPerSec:float = 1

#SLOW
signal staminaChanged(rawStaminaVal, minVal, maxVal)

func changeStamina(amount:float): #main function used for altering stamina
	stamina = clamp(stamina+amount, minStamina, maxStamina)
	emit_signal("staminaChanged", stamina, minStamina, maxStamina)

func refill():
	changeStamina(maxStamina)

func regen(delta:float):
	changeStamina(regenPerSec*delta)

func _process(delta):
	regen(delta)
