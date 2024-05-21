extends Node3D

#TODO
#will later have a bunch of nodes handling the enemy spawning and combat

class_name Main

@export var allEnemies:Array[CharacterBody3D]
@export var healthBarScene:PackedScene

#TEST
@onready var combat_manager = %combatManager

var healthBars

# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in allEnemies:
		enemy.connect("targetFreed", Callable(combat_manager, "lostTarget"))
		enemy.connect("targetNoticed", Callable(combat_manager, "enemyNoticedTarget"))
		enemy.connect("died", Callable(combat_manager, "enemyForgotTarget"))
	

func _process(delta):
	pass

func createHealthBar():
	pass
