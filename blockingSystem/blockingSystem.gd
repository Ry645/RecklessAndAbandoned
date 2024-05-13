extends Node

class_name ParrySystem

signal damageHealth(damage)
signal attackParried
signal attackBlocked

var elapsedBlockTime:float = 0.0

var isBlocking:bool = false
var canStartBlock:bool = true

var parryWindow:float = 0.25
var parryCooldown:float = 0.5 #only on fail
var recentlyParried:bool = false
var canParry:bool = false
var isCoyoteParrying:bool = false

@export var willEverBlock:bool = true

func startBlock():
	if canStartBlock:
		elapsedBlockTime = 0.0
		canParry = true # you can parry
		recentlyParried = false # no you just started a block
		isBlocking = true # yes you are blocking
		canStartBlock = false # no you can't block while blocking you already are

func endBlock():
	if isCoyoteParrying: # wait for the endBlock to finish man
		return
	
	if elapsedBlockTime < parryWindow: # if tapped the parry button
		#print("hey")
		isCoyoteParrying = true
		await get_tree().create_timer(parryWindow-elapsedBlockTime).timeout
		#print("listen")
	isCoyoteParrying = false
	isBlocking = false
	elapsedBlockTime = 0.0
	if recentlyParried: # skip parry cooldown
		canStartBlock = true
	else: # wait it out
		await get_tree().create_timer(0.5).timeout
		canStartBlock = true

func takeDamage(damage):
	if isBlocking:
		if elapsedBlockTime < parryWindow && canParry:
			print("parried!")
			emit_signal("attackParried")
			canParry = false
			recentlyParried = true
		else:
			print("blocked")
			emit_signal("attackBlocked")
			recentlyParried = false
	else:
		recentlyParried = false
		emit_signal("damageHealth", damage)

func _process(delta):
	if isBlocking:
		elapsedBlockTime += delta



#have button combo to force block instead of parry
#also make temper meter to punish reckless play but to give margin of error
