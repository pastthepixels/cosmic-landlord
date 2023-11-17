extends Node

@export_category("Climate")
@export_range(-1, 1) var delta_temperature_level : float
@export_range(-1, 1) var delta_oxygen_level : float
@export_range(-1, 1) var delta_carbon_dioxide_level : float
@export_range(-1, 1) var delta_water_to_land_ratio : float

@export_category("Price")
@export var delta_cost : int
@export var upfront_cost : int

@export_category("")
@export var planet_path : NodePath

var planet

signal take_money_request

func _ready():
	if planet_path != null: planet = get_node(planet_path)

func get_time_left():
	return $Timer.time_left / $Timer.wait_time

func set_planet(planet):
	self.planet = planet


func _on_timer_timeout():
	emit_signal("take_money_request", self)
	planet.set_temperature_level(planet.temperature_level + delta_temperature_level)
	planet.set_oxygen_level(planet.oxygen_level + delta_oxygen_level)
	planet.set_carbon_dioxide_level(planet.carbon_dioxide_level + delta_carbon_dioxide_level)
	planet.set_water_to_land_ratio(planet.water_to_land_ratio + delta_water_to_land_ratio)
