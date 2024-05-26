extends Node

class_name LockOnSystem

var enemyManager:EnemyManager
var camera:Camera3D
var player:Player
var targetedEnemy
var lockOnRange:float = 500.0

var isLockedOn:bool
var lockOnTarget

signal updateCursor(closestEnemy:CharacterBody3D)
signal disappearCursor
signal setCursorState(cursorState:int)

enum CursorState {
	DEFAULT,
	LOCKED
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#SLOW
func _physics_process(_delta: float) -> void:
	targetingProcess()
	updateCursorPosition()

#INFO
#template for setting vars from now on
func setVarsFromMain(main:Main):
	enemyManager = main.enemy_manager
	camera = main.player.camera
	player = main.player

#TEST
#add manual lock on later
#like a cursor hovering over screen
func lockOn():
	isLockedOn = true
	emit_signal("setCursorState", CursorState.LOCKED)

func targetingProcess():
	if isLockedOn:
		return
	
	var closestEnemy = null
	var closestDistance = lockOnRange
	for enemy in enemyManager.allEnemies:
		if !camera.is_position_behind(enemy.global_position):
			if (player.global_position - enemy.global_position).length() < closestDistance:
				closestEnemy = enemy
				closestDistance = (player.global_position - enemy.global_position).length()
	
	targetedEnemy = closestEnemy

func updateCursorPosition():
	if targetedEnemy != null && !camera.is_position_behind(targetedEnemy.global_position):
		emit_signal("updateCursor", targetedEnemy)
	else:
		emit_signal("disappearCursor")
