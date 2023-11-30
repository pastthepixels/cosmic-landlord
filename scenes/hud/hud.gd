extends Node

func update(money, payday_cooldown_value, year):
	$%Balance.text = "$%d" % money
	$"%YearProgress/ProgressBar".value = payday_cooldown_value
	$"%YearText/Label".text = "Year %d" % year


func _on_view_tenants_pressed():
	$%DemandHUD.visible = not $%DemandHUD.visible

func initialise_demand_hud():
	$%DemandHUD.initialise()

func show_planet_hud(planet):
	$%PlanetHUD.set_up(planet)
	$%PlanetHUD.show()
	planet.hud = $%PlanetHUD

func hide_planet_hud():
	$%PlanetHUD._planet.hud = null
	$%PlanetHUD._planet = null
	$%PlanetHUD.hide()

func _on_planet_hud_purchase_pressed():
	$%PlanetHUD._planet._on_planet_hud_purchase_pressed()


func _on_planet_hud_exited():
	$%PlanetHUD._planet._on_planet_hud_exited()


func _on_planet_hud_request_purchase_machines():
	$%PlanetHUD._planet._on_planet_hud_request_purchase_machines()
