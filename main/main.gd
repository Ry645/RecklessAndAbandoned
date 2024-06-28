extends Node3D

#TODO new feature
#will later have a bunch of nodes handling the enemy spawning and combat

class_name Main


@export var player:Player
@export var devSettingsEnabled:bool = false
@export var enemyClass:PackedScene

@onready var hud_layer:HudLayer = %hudLayer
#TEST eventually get all combat managers in the level
@onready var combat_manager = %combatManager
@onready var enemy_manager:EnemyManager = $enemyManager

# Called when the node enters the scene tree for the first time.
func _ready():
	#set all enemies
	enemy_manager.allEnemies = getEnemies()
	
	#loops through all enemies
	hud_layer.playerCamera = player.camera
	
	#lock on system
	player.lock_on_system.setVarsFromMain(self)
	lockOnSystemConnectSignals()
	
	player.health_system.connect("healthUpdate", Callable(hud_layer.health_bar, "_on_health_update"))
	player.health_system.connect("setHealthBarVars", Callable(hud_layer.health_bar, "_on_set_health_bar_vars"))
	#HACK
	player.health_system._ready()
	
	for i in range(enemy_manager.allEnemies.size()):
		setUpEnemySignals(enemy_manager.allEnemies[i])
	

func _process(delta):
	if devSettingsEnabled:
		if Input.is_action_just_pressed("spawnEnemy"):
			#TEST doesn't add a health bar
			var node = enemyClass.instantiate() as Grunt
			call_deferred("setUpEnemySignals", node)
			add_child(node)
			node.global_position = player.global_position
			node.targetBody = player

func getEnemies():
	return get_tree().get_nodes_in_group("enemy")

func lockOnSystemConnectSignals():
	player.lock_on_system.connect("updateCursor", Callable(hud_layer, "updateLockOnCursorFromAutoTarget"))
	player.lock_on_system.connect("disappearCursor", Callable(hud_layer, "disappearLockOnCursor"))
	player.lock_on_system.connect("setCursorState", Callable(hud_layer.lock_on_cursor, "setCursorState"))
	player.lock_on_system.connect("setCursorState", Callable(hud_layer, "setCursorState"))
	player.lock_on_system.connect("updatePreviewCursorPosition", Callable(hud_layer, "updatePreviewLockCursor"))

func enemyManagerConnectSignals(enemy):
	enemy.connect("died", Callable(enemy_manager, "removeEnemy"))

func combatManagerConnectSignals(enemy):
	enemy.connect("targetFreed", Callable(combat_manager, "lostTarget"))
	enemy.connect("targetNoticed", Callable(combat_manager, "enemyNoticedTarget"))
	enemy.connect("died", Callable(combat_manager, "enemyForgotTarget"))

func setUpEnemySignals(enemy):
	combatManagerConnectSignals(enemy)
	enemy.connect("died", Callable(hud_layer, "deleteHealthBar"))
	
	
	enemy.connect("mouseHoveredOverMe", Callable(player.lock_on_system, "setHoveredTarget"))
	
	enemyManagerConnectSignals(enemy)
	
	#TODO enemy manager setup : complex and annoying
	#HACK
	#later make this attached to enemy manager in some way
	hud_layer.setHealthBarVars(enemy)
