extends ScrollContainer

var planet_stats_scene = preload("res://scenes/planet_hud/planet_stats.tscn")

func initialise():
	for tribe in get_tree().get_nodes_in_group("tribes"):
		var stats = planet_stats_scene.instantiate()
		stats.set_stats(
			tribe.temperature_level,
			tribe.oxygen_level,
			tribe.carbon_dioxide_level,
			tribe.water_to_land_ratio,
			tribe.name
		)
		$VBoxContainer.add_child(stats)


func _on_hide_button_pressed():
	hide()
