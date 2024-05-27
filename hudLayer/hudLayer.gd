extends CanvasLayer

class_name HudLayer

@export var healthBarScene:PackedScene

var characters:Array[CharacterBody3D]
var healthBars:Array[HealthBar]
var playerCamera:Camera3D
var currentCursorState:int = 0

@onready var lock_on_cursor: Control = %lockOnCursor
@onready var health_bar: HealthBar = %healthBar


enum CursorState {
	DEFAULT,
	LOCKED
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	updateHealthBarPosition()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if currentCursorState == 1:
			updateCursorPositionFromMouse(event)

func updateHealthBarPosition():
	for i in range(healthBars.size()):
		healthBars[i].position = playerCamera.unproject_position(characters[i].health_bar_position.global_position) + healthBars[i].positionOffset
		if playerCamera.is_position_behind(characters[i].health_bar_position.global_position):
			healthBars[i].visible = false
		else:
			healthBars[i].visible = true

func updateCursorPositionFromMouse(event:InputEventMouseMotion):
	lock_on_cursor.position = event.position

func setHealthBarVars(character, _index:int):
	characters.append(character)
	var newHealthBar
	if character.healthBarScene:
		newHealthBar = character.healthBarScene.instantiate()
	else:
		newHealthBar = healthBarScene.instantiate()
	character.health_system.connect("healthUpdate", Callable(newHealthBar, "_on_health_update"))
	character.health_system.connect("setHealthBarVars", Callable(newHealthBar, "_on_set_health_bar_vars"))
	add_child(newHealthBar)
	healthBars.append(newHealthBar)
	#HACK
	#sort of
	#probably bad practice but I don't care
	character.health_system._ready()

func deleteHealthBar(character):
	var i = characters.find(character)
	characters.remove_at(i)
	healthBars[i].queue_free()
	healthBars.remove_at(i)

func updateLockOnCursorFromAutoTarget(closestEnemy:CharacterBody3D):
	lock_on_cursor.visible = true
	lock_on_cursor.position = playerCamera.unproject_position(closestEnemy.global_position)

func disappearLockOnCursor():
	lock_on_cursor.visible = false

func setCursorState(state:int):
	currentCursorState = state
	if state == 1:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
