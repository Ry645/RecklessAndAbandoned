extends Node

class_name CombatManager

var targetBody:CharacterBody3D
var attackingEnemies:Array[CharacterBody3D]
var engagedEnemy:CharacterBody3D

func gainTarget(attackingEnemiesIndex:int = 0):
	if attackingEnemies.size() == 0:
		print("no enemies left")
		return
	
	attackingEnemies[attackingEnemiesIndex].target()
	engagedEnemy = attackingEnemies[attackingEnemiesIndex]

func lostTarget(selfRef):
	attackingEnemies.erase(selfRef)
	attackingEnemies.append(selfRef)
	gainTarget()

func enemyForgotTarget(selfRef):
	attackingEnemies.erase(selfRef)
	gainTarget()

func enemyNoticedTarget(targetBody1, selfRef):
	targetBody = targetBody1
	attackingEnemies.append(selfRef)
	if engagedEnemy == null:
		gainTarget()
	
