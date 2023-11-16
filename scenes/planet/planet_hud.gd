extends ScrollContainer

signal exited

signal purchase_pressed

var label_scene = preload("res://scenes/planet/planet_hud_label.tscn")

func _on_back_button_pressed():
	emit_signal("exited")

func _on_purchase_button_pressed():
	emit_signal("purchase_pressed")

func set_up(planet):
	if planet.purchased:
		unlock()

func add_population_sliders(planet):
	for tribe in planet.population:
		var label = label_scene.instantiate()
		label.name = tribe
		label.get_node("ProgressBar").hide()
		$%Population/VBoxContainer.add_child(label)

func update(planet):
	$%PlanetStats.set_stats(
		planet.temperature_level,
		planet.oxygen_level,
		planet.carbon_dioxide_level,
		planet.water_to_land_ratio,
		"Planet " + planet.planet_name
	)
	for tribe in planet.population:
		if has_node("%" + ("Population/VBoxContainer/%s" % tribe)):
			print(true)
			get_node("%" + ("Population/VBoxContainer/%s" % tribe)).visible = planet.population[tribe] > 0
			get_node("%" + ("Population/VBoxContainer/%s/Label" % tribe)).text = (tribe + ": %d") % planet.population[tribe]
	$%PopTotal/ProgressBar.value = planet.get_population_count() / float(planet.max_population)
	
	$%PurchaseButton.text = "Purchase ($%d)" % planet.price

func unlock():
	$%PurchaseButton.disabled = true
	$%Machines.show()
	$%Population.show()
