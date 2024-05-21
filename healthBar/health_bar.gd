#INFO
#use camera.unproject_position(Vector3) for the health bars appearing above enemies

extends ProgressBar

class_name HealthBar

@onready var healthText = %healthText


func _on_player_health_update(health):
	value = health
	healthText = %healthText # needed b/c onready order is off
	healthText.text = str(health)


func _on_player_set_health_bar_vars(minHealth, maxHealth, currentHealth):
	min_value = minHealth
	max_value = maxHealth
	_on_player_health_update(currentHealth)
