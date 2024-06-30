#START add stamina bar
#TODO stamina: simple
#remove block cooldown and replace with 3 tick stamina bar for starting blocks
#TODO and indicate player block state with a circle outline at the player's feet
#TODO improve parry animation so the parry stance comes up instantly with some kind of visual flash, and after the parry window is over, slowly return to holdSwordArm (like Lucina parry down special fail)

extends Node

class_name BlockingSystem

signal damageHealth(damage)
signal attackParried
signal attackBlocked
signal blockStarted
signal blockEnded
signal parryWindowEnded

var elapsedBlockTime:float = 0.0

enum BlockMode{
	BLOCK,
	PARRY
}
var currentBlockMode = BlockMode.BLOCK
var isBlocking:bool = false # depends on your block state whether you parry or hard block
var canBlock:bool

var parryWindow:float = 0.25

@export var willEverBlock:bool = true
@export var blockDamageReduction:float = 0.5

func incrementBlockMode(num = 1):
	currentBlockMode = FunctionLibrary.positiveModFunctionIStoleFromStackOverflow(currentBlockMode+num, 2)

func startBlock():
	if canBlock:
		emit_signal("blockStarted")
		elapsedBlockTime = 0.0
		isBlocking = true # yes you are blocking

func endBlock():
	if currentBlockMode == 1 && elapsedBlockTime < parryWindow: # if tapped the parry button
		return
	
	blockTimeOut()

func blockTimeOut():
	isBlocking = false
	elapsedBlockTime = 0.0
	emit_signal("blockEnded")

func takeDamage(damage):
	if isBlocking:
		if currentBlockMode == 1:
			print("parried!")
			emit_signal("attackParried")
			isBlocking = false
			elapsedBlockTime = 0.0
		else:
			print("blocked")
			emit_signal("attackBlocked")
			emit_signal("damageHealth", damage * blockDamageReduction)
	else:
		print("ow")
		emit_signal("damageHealth", damage)

func _process(delta):
	if isBlocking:
		elapsedBlockTime += delta
		if elapsedBlockTime >= parryWindow && currentBlockMode == 1:
			blockTimeOut()
			emit_signal("parryWindowEnded")



#have button combo to force block instead of parry
#also make temper meter to punish reckless play but to give margin of error
