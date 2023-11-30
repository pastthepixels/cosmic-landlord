extends ScrollContainer

signal exited

signal purchase_pressed

signal request_purchase_machines

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

func update_machine_sliders(planet):
	for machine in planet.get_node("Machines").get_children():
		if has_node("%" + ("Machines/VBoxContainer/%s" % machine.name)):
			get_node("%" + ("Machines/VBoxContainer/%s/ProgressBar" % machine.name)).value = machine.get_time_left()
		else:
			var label = label_scene.instantiate()
			label.name = machine.name
			label.get_node("Label").text = machine.name
			label.get_node("ProgressBar").value = machine.get_time_left()
			$%Machines/VBoxContainer.add_child(label)

func remove_machine_slider(machine):
	if has_node("%" + ("Machines/VBoxContainer/%s" % machine.name)):
		get_node("%" + ("Machines/VBoxContainer/%s" % machine.name)).queue_free()

func update(planet):
	# Planet stats
	$%PlanetStats.set_stats(
		planet.temperature_level,
		planet.oxygen_level,
		planet.carbon_dioxide_level,
		planet.water_to_land_ratio,
		"Planet " + planet.planet_name
	)
	# Tribes
	for tribe in planet.population:
		if has_node("%" + ("Population/VBoxContainer/%s" % tribe)):
			var growth_symbol = ("↑" if planet.population_rate[tribe] > 0 else "↓") if planet.population_rate[tribe] != 0 else "-"
			get_node("%" + ("Population/VBoxContainer/%s" % tribe)).visible = planet.population[tribe] > 0
			get_node("%" + ("Population/VBoxContainer/%s/Label" % tribe)).text = growth_symbol + " " + (tribe + ": %d") % planet.population[tribe]
	$%PopTotal/ProgressBar.value = planet.get_population_count() / float(planet.max_population)
	# Purchasing
	$%PurchaseButton.text = "Purchase ($%d)" % planet.price
	# Machine!!
	if planet.has_node("Machines"): update_machine_sliders(planet)

func unlock():
	$%PurchaseButton.disabled = true
	$%Machines.show()
	$%Population.show()


func _on_purchase_machine_pressed():
	emit_signal("request_purchase_machines")
