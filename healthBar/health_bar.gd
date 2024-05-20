extends ProgressBar




func _on_player_health_update(health):
	value = health


func _on_player_set_health_bar_vars(minHealth, maxHealth, currentHealth):
	min_value = minHealth
	max_value = maxHealth
	value = currentHealth
