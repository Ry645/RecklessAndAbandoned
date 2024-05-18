extends ShapeCast3D

class_name Hurtbox

#TODO
#later to damage res
@export var damageValue:float
@export var activeFrames:int = 1

# Called when the node enters the scene tree for the first time.
func _process(delta):
	for body in whatever:
		if body.has_method("takeDamage"):
			body.takeDamage(damageValue)
	
	if activeFrames <= 0:
		queue_free()
	activeFrames -= 1


