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
	#print(playerCamera.global_basis.z)
	print((-playerCamera.global_basis.z).normalized().dot((healthBarPositionNodes[0].global_position-playerCamera.global_position).normalized()))
	for i in range(healthBars.size()):
		healthBars[i].position = playerCamera.unproject_position(healthBarPositionNodes[i].global_position)
		if (-playerCamera.global_basis.z).normalized().dot((healthBarPositionNodes[i].global_position-playerCamera.global_position).normalized()) < 0:
			healthBars[i].visible = false
		else:
			healthBars[i].visible = true

func setHealthBarVars(healthBarPositionNode, index:int):
	healthBarPositionNodes.append(healthBarPositionNode)
	var newHealthBar = healthBarScene.instantiate()
	add_child(newHealthBar)
	healthBars.append(newHealthBar)

func deleteHealthBar(enemy):
	var i = healthBarPositionNodes.find(enemy.health_bar_position)
	healthBarPositionNodes.remove_at(i)
	healthBars[i].queue_free()
	healthBars.remove_at(i)
