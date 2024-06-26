#HACK
#this thing's existence is a hack but I couldn't be bothered to make anything better

extends Node3D

class_name StatusEffectHolder

signal damage(damageVal)

#name, duration, tickInterval, damage, timeSinceTick
var dictStatusEffect = {
	"Fire" = ["Fire", 3.0, 1.0, 5.0, 0.0],
	"Magma" = ["Magma", -1.0, 1.0, 10.0, 0.0]
	
}

@export var statusEffects:Array[Array]

#TODO
#maybe add a max to the duration on multiple hits
func gainEffect(effect:String):
	if !dictStatusEffect.has(effect):
		print(self, ": status effect does not exist")
		return
	
	var index = FunctionLibrary.keySearch(statusEffects, effect)
	if index != -1:
		statusEffects[index][1] += dictStatusEffect[effect][1]
		return
	statusEffects.append(dictStatusEffect[effect])

func loseEffect(effect:String):
	for i in range(statusEffects.size()): #search and destroy
		if statusEffects[i][0] == effect:
			statusEffects.remove_at(i)
			break
	

#INFO
#handle each status effect manually here
func _physics_process(delta):
	for effect in statusEffects:
		if effect[2] != -1 && effect[2] < effect[4]: #if i say so and long enough then fire effect damage
			effect[4] = 0.0
			match effect[0]:
				"Fire":
					emit_signal("damage", effect[3])
				"Magma":
					emit_signal("damage", effect[3])
				
		
		
		
		if effect[1] == -1:
			continue
		effect[1] -= delta
		effect[4] += delta
		
		if effect[1] < 0:
			loseEffect(effect[0])
