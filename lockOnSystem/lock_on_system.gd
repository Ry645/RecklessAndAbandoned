extends Node

class_name LockOnSystem

@onready var main:Node3D

var enemyManager
var camera:Camera3D
var player:Player

signal updateCursor(closestEnemy:CharacterBody3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#SLOW
func _process(_delta: float) -> void:
	var closestEnemy = enemyManager.allEnemies[0]
	for enemy in enemyManager.allEnemies:
		#BUG
		#need to update original array in enemy manager in order for this to work
		if camera.is_position_behind(enemy.global_position):
			if (player.global_position - enemy.global_position).length() < (player.global_position - closestEnemy.global_position).length():
				closestEnemy = enemy
	emit_signal("updateCursor", closestEnemy)

#INFO
#template for setting vars from now on
func setVarsFromMain(main:Main):
	enemyManager = main.enemy_manager
	camera = main.player.camera
	player = main.player
