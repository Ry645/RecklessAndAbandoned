#BUG
#enemies take damage from their own attacks
#so does the player
#fix this soon

extends Area3D

class_name Hurtbox

#TODO
#later to damage res
@export var damageValue:float
@export var activeFrames:int = 1

#INFO
#for anything for detecting collision or anything else
#in the game world, use _physics_process instead of _process
func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.has_method("takeDamage"):
			body.takeDamage(damageValue)
	
	if activeFrames <= 0:
		queue_free()
	activeFrames -= 1


