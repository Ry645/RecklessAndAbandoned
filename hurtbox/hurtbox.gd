extends Area3D

class_name Hurtbox

#TODO
#later to damage res
@export var damageValue:float

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_overlapping_bodies())
	for body in get_overlapping_bodies():
		if body.has_method("takeDamage"):
			body.takeDamage(damageValue)
	
	queue_free()


