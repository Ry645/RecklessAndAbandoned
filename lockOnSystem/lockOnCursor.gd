extends Control

@export var cursorStates:Array[Texture]
@onready var texture_rect: TextureRect = %TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setCursorState(state:int):
	texture_rect.texture = cursorStates[state]
