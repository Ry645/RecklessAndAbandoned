extends Control

class_name StaminaBar

var staminaTickNumber:int = 3
@onready var tick_1:TextureProgressBar = $tick1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update(stamina:float, minVal, maxVal):
	tick_1.value = stamina
	tick_1.min_value = minVal
	tick_1.max_value = maxVal
