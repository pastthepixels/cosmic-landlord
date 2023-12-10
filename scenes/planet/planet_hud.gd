extends ScrollContainer

signal exited

signal purchase_pressed

signal request_purchase_machines

var label_scene = preload("res://scenes/planet/planet_hud_label.tscn")

var _planet

func _process(delta):
	if _planet != null and visible:
		update(_planet)

func _on_back_button_pressed():
	emit_signal("exited")

func _on_purchase_button_pressed():
	emit_signal("purchase_pressed")

func set_up(planet):
	reset()
	_planet = planet
	if planet.purchased:
		unlock()

func reset():
	lock()
	for child in $%PopulationContainer.get_children():
		child.hide()
	for child in $%MachinesContainer.get_children():
		child.name = ""
		child.queue_free()

func update_population_sliders(planet):
	for tribe in planet.population:
		var label = get_node("%" + ("PopulationContainer/%s" % tribe)) if has_node("%" + ("PopulationContainer/%s" % tribe)) else label_scene.instantiate()
		if not has_node("%" + ("PopulationContainer/%s" % tribe)):
			$%PopulationContainer.add_child(label)
		# Update existing labels
		var growth_symbol = ("↑" if planet.population_rate[tribe] > 0 else "↓") if planet.population_rate[tribe] != 0 else "-"
		label.name = tribe
		label.get_node("ProgressBar").hide()
		label.visible = planet.population[tribe] > 0
		label.get_node("Label").text = growth_symbol + " " + (tribe + ": %d") % planet.population[tribe]

	$%PopTotal/ProgressBar.value = planet.get_population_count() / float(planet.max_population)


func update_machine_sliders(planet):
	for machine in planet.get_node("Machines").get_children():
		if has_node("%" + ("MachinesContainer/%s" % machine.name)):
			get_node("%" + ("MachinesContainer/%s/ProgressBar" % machine.name)).value = machine.get_time_left()
		else:
			var label = label_scene.instantiate()
			label.name = machine.name
			label.get_node("Label").text = machine.name
			label.get_node("ProgressBar").value = machine.get_time_left()
			$%MachinesContainer.add_child(label)

func remove_machine_slider(machine):
	if has_node("%" + ("MachinesContainer/%s" % machine.name)):
		get_node("%" + ("MachinesContainer/%s" % machine.name)).queue_free()

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
	update_population_sliders(planet)
	# Purchasing
	$%PurchaseButton.text = "Purchase ($%d)" % planet.price
	# Machine!!
	if planet.has_node("Machines"): update_machine_sliders(planet)

func unlock():
	$%PurchaseButton.disabled = true
	$%Machines.show()
	$%Population.show()

func lock():
	$%PurchaseButton.disabled = false
	$%Machines.hide()
	$%Population.hide()


func _on_purchase_machine_pressed():
	emit_signal("request_purchase_machines")
