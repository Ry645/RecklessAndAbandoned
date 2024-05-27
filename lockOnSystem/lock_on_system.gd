extends Node

class_name LockOnSystem

var enemyManager:EnemyManager
var camera:Camera3D
var player:Player
var targetedEnemy
var lockOnRange:float = 500.0

var currentLockState:int = LockOnState.DEFAULT
var lockOnTarget
var targetingFromThisTarget

signal updateCursor(closestEnemy:CharacterBody3D)
signal disappearCursor
signal setCursorState(cursorState:int)
signal updatePreviewCursorPosition(enemy)

enum LockOnState {
	DEFAULT,
	READY,
	LOCKED
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#SLOW
func _physics_process(_delta: float) -> void:
	targetingProcess()
	updateCursorPositionFromAutoLock()

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
	setAndNotifyLockOnState(LockOnState.LOCKED)

func readyLockOn():
	targetingFromThisTarget = targetedEnemy
	setAndNotifyLockOnState(LockOnState.READY)

func tryLockOn():
	if targetingFromThisTarget == targetedEnemy:
		setAndNotifyLockOnState(LockOnState.DEFAULT)
	else:
		setAndNotifyLockOnState(LockOnState.LOCKED)

func targetingProcess():
	if currentLockState != LockOnState.DEFAULT:
		return
	
	var closestEnemy = null
	var closestDistance = lockOnRange
	for enemy in enemyManager.allEnemies:
		if !camera.is_position_behind(enemy.global_position):
			if (player.global_position - enemy.global_position).length() < closestDistance:
				closestEnemy = enemy
				closestDistance = (player.global_position - enemy.global_position).length()
	
	targetedEnemy = closestEnemy

func updateCursorPositionFromAutoLock():
	if targetedEnemy != null && !camera.is_position_behind(targetedEnemy.global_position):
		if currentLockState != LockOnState.READY:
			emit_signal("updateCursor", targetedEnemy)
			emit_signal("updatePreviewCursorPosition", null)
		else:
			emit_signal("updatePreviewCursorPosition", targetedEnemy)
	else:
		emit_signal("disappearCursor")

func setHoveredTarget(enemy):
	if currentLockState == LockOnState.READY:
		targetedEnemy = enemy

func setAndNotifyLockOnState(state:int):
	currentLockState = state
	emit_signal("setCursorState", state)
