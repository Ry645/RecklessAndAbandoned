extends Node3D

#TODO
#will later have a bunch of nodes handling the enemy spawning and combat

class_name Main

#TEST
@export var allEnemies:Array[CharacterBody3D]
@export var player:Player

@onready var hud_layer:HudLayer = %hudLayer
#TEST
@onready var combat_manager = %combatManager

# Called when the node enters the scene tree for the first time.
func _ready():
	#loops through all enemies
	hud_layer.playerCamera = player.camera
	
	#lock on system
	player.lock_on_system.setVarsFromMain(self)
	player.lock_on_system.connect("updateCursor", Callable(hud_layer, "updateLockOnCursor"))
	
	for i in range(allEnemies.size()):
		combat_manager.connectSignalsFromEnemyToSelf(allEnemies[i])
		allEnemies[i].connect("died", Callable(hud_layer, "deleteHealthBar"))
		
		
		#TODO
		#HACK
		#later make this attached to enemy manager in some way
		hud_layer.setHealthBarVars(allEnemies[i], i)
	


