extends Node3D

#TODO
#will later have a bunch of nodes handling the enemy spawning and combat

class_name Main

#TEST
@export var allEnemies:Array[CharacterBody3D]
@export var player:CharacterBody3D

@onready var hud_layer:HudLayer = %hudLayer
#TEST
@onready var combat_manager = %combatManager

# Called when the node enters the scene tree for the first time.
func _ready():
	#loops through all enemies
	hud_layer.playerCamera = player.camera
	
	for i in range(allEnemies.size()):
		allEnemies[i].connect("targetFreed", Callable(combat_manager, "lostTarget"))
		allEnemies[i].connect("targetNoticed", Callable(combat_manager, "enemyNoticedTarget"))
		allEnemies[i].connect("died", Callable(combat_manager, "enemyForgotTarget"))
		
		hud_layer.setHealthBarVars(allEnemies[i].health_bar_position, i)
	

#func createHealthBar():
	#pass
