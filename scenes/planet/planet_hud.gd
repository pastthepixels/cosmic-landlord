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

func unlock():
	$%PurchaseButton.disabled = true
	$%Machines.show()
	$%Population.show()
