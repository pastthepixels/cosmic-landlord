extends Node

var rng = RandomNumberGenerator.new()

# Look at planet/planet.gd
@export_category("Climate")
@export var randomly_generated_climate : bool = false
@export_range(-0.5, 0.5) var temperature_level : float
@export_range(0, 1) var oxygen_level : float
@export_range(0, 1) var carbon_dioxide_level : float
@export_range(0, 1) var water_to_land_ratio : float

@export_category("Money making")
# Every pay cycle you get $x/person who's on one of your planets
@export var randomly_generated_payback : bool = false
@export var payback : int


@onready var names_file = FileAccess.open("res://res/tribe_names.txt", FileAccess.READ)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	name = gen_name()
	if randomly_generated_climate:
		generate_random_climate()
	if randomly_generated_payback:
		payback = rng.randf_range(1, 2)

func generate_random_climate():
	temperature_level	 = rng.randf_range(-0.5, 0.5)
	oxygen_level		 = rng.randf_range(0, 1)
	carbon_dioxide_level = rng.randf_range(0, 1)
	water_to_land_ratio	 = rng.randf_range(0, 1)

func gen_name():
	var possible_names = names_file.get_as_text().split("\n")
	var generated_name = possible_names[rng.randi_range(0, possible_names.size() - 1)].strip_edges()
	# Checks to see if the name is blank (for some reason???)
	if generated_name.length() <= 0: return gen_name()
	# Checks to see if the name doesn't already exist
	for tribe in get_tree().get_nodes_in_group("tribes"):
		if tribe != self and tribe.name == generated_name:
			return gen_name()
	return generated_name

# Climate similarity:
# the amount of the largest distance between any given values representing a climate
# (for instance, if the temperature has the largest difference, it is used)
# 1 == most similar (matching)
func get_climate_similarity(planet):
	return 1 - max(
			abs(self.temperature_level - planet.temperature_level),
			abs(self.oxygen_level - planet.oxygen_level),
			abs(self.carbon_dioxide_level - planet.carbon_dioxide_level),
			abs(self.water_to_land_ratio - planet.water_to_land_ratio)
		)
