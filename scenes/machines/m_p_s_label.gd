extends PanelContainer

signal request_destroy

signal request_purchase

var machine

func set_stats(machine):
	self.machine = machine
	$%Name.text = machine.name
	# Cost/wait time
	$%CostPerRun/Value.text = "$%d" % machine.delta_cost
	$%CooldownTime/Value.text = str(machine.get_node("Timer").wait_time)
	# Changes in things
	$%delta_temperature_level/Value.text = "%.2f" % (machine.delta_temperature_level * 100) + "%"
	$%delta_temperature_level.visible = machine.delta_temperature_level != 0
	$%delta_oxygen_level/Value.text = "%.2f" % (machine.delta_oxygen_level * 100) + "%"
	$%delta_oxygen_level.visible = machine.delta_oxygen_level != 0
	$%delta_carbon_dioxide_level/Value.text = "%.2f" % (machine.delta_carbon_dioxide_level * 100) + "%"
	$%delta_carbon_dioxide_level.visible = machine.delta_carbon_dioxide_level != 0
	$%delta_water_to_land_ratio/Value.text = "%.2f" % (machine.delta_water_to_land_ratio * 100) + "%"
	$%delta_water_to_land_ratio.visible = machine.delta_water_to_land_ratio != 0

func set_purchasable():
	$VBoxContainer/Destroy.hide()
	$VBoxContainer/Purchase.show()


func _on_destroy_pressed():
	if self.machine != null: emit_signal("request_destroy", machine)
	queue_free()


func _on_purchase_pressed():
	if self.machine != null: emit_signal("request_purchase", machine)
