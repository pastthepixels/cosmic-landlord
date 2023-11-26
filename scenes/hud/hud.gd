extends Node

signal view_tenants

func update(money, payday_cooldown_value, year):
	$%Balance.text = "$%d" % money
	$"%YearProgress/ProgressBar".value = payday_cooldown_value
	$"%YearText/Label".text = "Year %d" % year


func _on_view_tenants_pressed():
	emit_signal("view_tenants")
