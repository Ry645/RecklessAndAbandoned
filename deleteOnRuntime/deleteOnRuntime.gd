extends Node

class_name DeleteOnRuntime
#add this script to anything you want deleted at runtime
#but still shown in the editor

func _ready():
	queue_free()
