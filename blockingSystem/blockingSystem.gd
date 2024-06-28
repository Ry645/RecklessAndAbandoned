#TODO stamina: simple
#remove block cooldown and replace with 3 tick stamina bar for starting blocks
#switch between parry mode and block mode with F
#and indicate player block state with a circle outline at the player's feet

extends Node

class_name BlockingSystem

signal damageHealth(damage)
signal attackParried
signal attackBlocked
signal blockStarted
signal blockEnded
signal parryWindowEnded

var elapsedBlockTime:float = 0.0

var isBlocking:bool = false

var parryWindow:float = 0.25
var recentlyParried:bool = false
var canParry:bool = false

@export var willEverBlock:bool = true
@export var blockDamageReduction:float = 0.5

func startBlock():
	emit_signal("blockStarted")
	elapsedBlockTime = 0.0
	canParry = true # you can parry
	recentlyParried = false # no you just started a block
	isBlocking = true # yes you are blocking

func endBlock():
	if elapsedBlockTime < parryWindow: # if tapped the parry button
		return
	
	blockTimeOut()

func blockTimeOut():
	isBlocking = false
	elapsedBlockTime = 0.0
	emit_signal("blockEnded")

func takeDamage(damage):
	if isBlocking:
		if elapsedBlockTime < parryWindow && canParry:
			print("parried!")
			emit_signal("attackParried")
			canParry = false
			recentlyParried = true
			#if elapsedBlockTime < parryWindow: #cancel block when attack hits you so you can block again
				#blockTimeOut()
		else:
			print("blocked")
			emit_signal("attackBlocked")
			emit_signal("damageHealth", damage * blockDamageReduction)
			recentlyParried = false
	else:
		print("ow")
		recentlyParried = false
		emit_signal("damageHealth", damage)

func _process(delta):
	if isBlocking:
		elapsedBlockTime += delta
		if elapsedBlockTime >= parryWindow && canParry:
			emit_signal("parryWindowEnded")
			canParry = false



#have button combo to force block instead of parry
#also make temper meter to punish reckless play but to give margin of error
