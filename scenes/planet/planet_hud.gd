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
	$%Temp/ProgressBar.value = planet.temperature_level
	$%Oxygen/ProgressBar.value = planet.oxygen_level
	$"%Carbon Dioxide/ProgressBar".value = planet.carbon_dioxide_level
	$%Land_Water/ProgressBar.value = planet.water_to_land_ratio
	$%PurchaseButton.text = "Purchase ($%d)" % planet.price

func unlock():
	$%PurchaseButton.disabled = true
	$%Machines.show()
	$%Population.show()
