extends CanvasLayer

class_name HudLayer

@export var healthBarScene:PackedScene

var healthBarPositionNodes:Array[Node3D]
var healthBars:Array[HealthBar]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setHealthBarVars(healthBarPositionNode, index:int):
	healthBarPositionNodes.append(healthBarPositionNode)
	var newHealthBar = healthBarScene.instantiate()
	healthBars.append(newHealthBar)
