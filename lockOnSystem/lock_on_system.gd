extends Node

class_name LockOnSystem

@onready var main:Node3D

var enemyManager:EnemyManager
var camera:Camera3D
var player:Player
var targetedEnemy

signal updateCursor(closestEnemy:CharacterBody3D)
signal disappearCursor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#SLOW
func _process(_delta: float) -> void:
	if enemyManager.allEnemies.size() > 0:
		var closestEnemy = enemyManager.allEnemies[0]
		for enemy in enemyManager.allEnemies:
			if camera.is_position_behind(enemy.global_position):
				if (player.global_position - enemy.global_position).length() < (player.global_position - closestEnemy.global_position).length():
					closestEnemy = enemy
		emit_signal("updateCursor", closestEnemy)
		targetedEnemy = closestEnemy
	else:
		emit_signal("disappearCursor")
		targetedEnemy = null

#INFO
#template for setting vars from now on
func setVarsFromMain(main:Main):
	enemyManager = main.enemy_manager
	camera = main.player.camera
	player = main.player
