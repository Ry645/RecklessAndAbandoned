#BUG
#enemies take damage from their own attacks
#so does the player
#fix this soon

extends Area3D

class_name Hurtbox

@onready var timer = $Timer

#TODO
#later to damage res
@export var damageValue:float
@export var duration:float = 1
@export_enum("oneShot", "lingering") var hurtBoxType:int
@export var hitGroup:StringName = "hitGroup1"

#oneShot: tracks enemies so it doesn't hit them again
#lingering: tracks enemies currently in its radius to set status effects
var enteredBodies:Array

func _ready():
	add_to_group("hitGroup")
	timer.start(duration)

#INFO
#for anything for detecting collision or anything else
#in the game world, use _physics_process instead of _process
func _on_body_entered(body:Node3D):
	if !body.is_in_group(hitGroup):
		if body.has_method("takeDamage"):
			match hurtBoxType:
				0: #store some kind of array of nodes it hit so it doesn't hit them again
					for enteredBody in enteredBodies:
						if enteredBody == body:
							return
					
					enteredBodies.append(body)
					body.takeDamage(damageValue)
					
				1: #put status effect on enemy on enter and remove it on leave
					if body.has_node("statusEffectHolder"):
						body.get_node("statusEffectHolder").gainEffect("Fire") #TEST
					
	


func _on_timer_timeout():
	queue_free()
