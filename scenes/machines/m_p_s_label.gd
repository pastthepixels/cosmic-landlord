extends PanelContainer

signal request_destroy

signal request_purchase

var machine

func set_stats(machine):
	self.machine = machine
	$%Name.text = machine.name
	# Cost/wait time
	$%CostPerRun.text = "$%d/cycle" % machine.delta_cost
	$VBoxContainer/Purchase.text = "Purchase ($%d)" % machine.upfront_cost
	# Changes in things
	$%Temperature.text = ("+" if machine.delta_temperature_level > 0 else "-") + " Temperature"
	$%Temperature.visible = machine.delta_temperature_level != 0
	$%Oxygen.text = ("+" if machine.delta_oxygen_level > 0 else "-") + " Oxygen"
	$%Oxygen.visible = machine.delta_oxygen_level != 0
	$%CarbonDioxide.text = ("+" if machine.delta_carbon_dioxide_level > 0 else "-") + " Carbon Dioxide"
	$%CarbonDioxide.visible = machine.delta_carbon_dioxide_level != 0
	$%Water.text = ("+" if machine.delta_water_to_land_ratio > 0 else "-") + " Water"
	$%Water.visible = machine.delta_water_to_land_ratio != 0

func set_purchasable():
	$VBoxContainer/Destroy.hide()
	$VBoxContainer/Purchase.show()


func _on_destroy_pressed():
	if self.machine != null: emit_signal("request_destroy", machine)
	queue_free()


func _on_purchase_pressed():
	if self.machine != null: emit_signal("request_purchase", machine)
