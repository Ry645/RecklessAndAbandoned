extends Area3D

class_name Hurtbox

#TODO add more weapon types: new feature 
#TODO migrate all script dictionaries to their own static class : simple and annoying
var dictHurtBox:Dictionary = {
	"playerSword" = [20, 0.1, 0, 2],
	"gruntSword" = [20, 0.1, 0, 1]
}

@onready var timer = $Timer

#TODO but not really very important : new feature
#later to damage res
var propertyList:Array[String] = ["damageValue", "duration", "hurtBoxType", "hitGroup", "statusEffect"]

@export var damageValue:float
@export var duration:float = 1
@export_enum("oneShot", "lingering") var hurtBoxType:int
@export var hitGroup:StringName = "hitGroup1"
@export var statusEffect:String

#oneShot: tracks enemies so it doesn't hit them again
#lingering: tracks enemies currently in its radius to set status effects
var enteredBodies:Array

func setVars(hitBoxType):
	var array
	if hitBoxType is Array:
		array = hitBoxType
	elif hitBoxType is String:
		array = dictHurtBox[hitBoxType]
	
	if array[3] is int:
		array[3] = "hitGroup" + str(array[3])
	
	for i in range(array.size()):
		set(propertyList[i], array[i])

func _ready():
	add_to_group(hitGroup)
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
						body.get_node("statusEffectHolder").gainEffect(statusEffect)
					
	


func _on_timer_timeout():
	queue_free()
