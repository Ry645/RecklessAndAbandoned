extends CanvasLayer

class_name HudLayer

@export var healthBarScene:PackedScene

var characters:Array[CharacterBody3D]
var healthBars:Array[HealthBar]
var playerCamera:Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(healthBars.size()):
		healthBars[i].position = playerCamera.unproject_position(characters[i].health_bar_position.global_position)
		if playerCamera.is_position_behind(characters[i].health_bar_position.global_position):
			healthBars[i].visible = false
		else:
			healthBars[i].visible = true

func setHealthBarVars(character, _index:int):
	characters.append(character)
	var newHealthBar = healthBarScene.instantiate()
	character.health_system.connect("healthUpdate", Callable(newHealthBar, "_on_health_update"))
	character.health_system.connect("setHealthBarVars", Callable(newHealthBar, "_on_set_health_bar_vars"))
	add_child(newHealthBar)
	healthBars.append(newHealthBar)
	#HACK
	#sort of
	#character.health_system._ready()

func deleteHealthBar(character):
	var i = characters.find(character)
	characters.remove_at(i)
	healthBars[i].queue_free()
	healthBars.remove_at(i)
	
	

