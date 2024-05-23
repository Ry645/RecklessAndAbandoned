extends CanvasLayer

class_name HudLayer

@export var healthBarScene:PackedScene

var healthBarPositionNodes:Array[Node3D]
var healthBars:Array[HealthBar]
var playerCamera:Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(healthBars.size()):
		healthBars[i].position = playerCamera.unproject_position(healthBarPositionNodes[i].global_position)

func setHealthBarVars(healthBarPositionNode, index:int):
	healthBarPositionNodes.append(healthBarPositionNode)
	var newHealthBar = healthBarScene.instantiate()
	healthBars.append(newHealthBar)
