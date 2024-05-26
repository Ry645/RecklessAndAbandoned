extends Node

class_name EnemyManager

var allEnemies:Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func addEnemy(enemy:CharacterBody3D):
	allEnemies.append(enemy)

func removeEnemy(enemy:CharacterBody3D):
	allEnemies.erase(enemy)

func connectSignalsFromEnemyToSelf(enemy):
	enemy.connect("died", Callable(self, "removeEnemy"))

