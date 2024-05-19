extends Node3D

#TODO
#will later have a bunch of nodes handling the enemy spawning and combat

class_name Main

@export var allEnemies:Array[CharacterBody3D]

#TEST
@onready var combat_manager = %combatManager


# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in allEnemies:
		enemy.connect("targetFreed", Callable(combat_manager, "lostTarget"))
		enemy.connect("targetNoticed", Callable(combat_manager, "enemyNoticedTarget"))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
