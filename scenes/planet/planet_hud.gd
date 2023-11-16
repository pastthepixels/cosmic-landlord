extends ScrollContainer

signal exited

signal purchase_pressed

func _on_back_button_pressed():
	emit_signal("exited")

func _on_purchase_button_pressed():
	emit_signal("purchase_pressed")

func set_up(planet):
	if planet.purchased:
		unlock()

func update(planet):
	$%PlanetStats.set_stats(
		planet.temperature_level,
		planet.oxygen_level,
		planet.carbon_dioxide_level,
		planet.water_to_land_ratio,
		"Planet " + planet.planet_name
	)
	$%PurchaseButton.text = "Purchase ($%d)" % planet.price

func unlock():
	$%PurchaseButton.disabled = true
	$%Machines.show()
	$%Population.show()
