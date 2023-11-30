extends Node3D

@export_category("Climate")
@export var randomly_generated_climate : bool = false
# Averge surface temperature, simplified to be a range in -1 to 1 (however 0 == 0 degrees C)
@export_range(-0.5, 0.5) var temperature_level : float
# Oxygen level: percentage
@export_range(0, 1) var oxygen_level : float
# Carbon dioxide level: percentage
@export_range(0, 1) var carbon_dioxide_level : float
# Nitrogen level: percentage
#@export_range(0, 1) var nitrogen_level : float
# Percentage of surface occupied by water
@export_range(0, 1) var water_to_land_ratio : float

@export_category("Purchasing")
@export var price : int = 0 :
	get:
		return price * price_multiplier
@export var purchased : bool
# Affects machines and upfront cost
@export var price_multiplier : float = 1.0

@export_category("Other")
@export var planet_name = ""
@export var generate_name : bool = false

@export_category("Populations")
@export var max_population : int = 1000000
@export var max_population_rate : int = 1000
# Adjusts just how much a close climate affects a population rate
# note X is actually (x - 0.5) * 0.5 to get negative values if the similarity is < 0.5
# https://www.desmos.com/calculator/yqbyzdcqx7
@export var population_rate_gradient : float = 1
# I don't know what this does exactly (other than changes that 0.5 above)
# please comment this better if you can actually explain it
@export var climate_similarity_threshold : float = 0.6


@onready var names_file = FileAccess.open("res://res/planet_names.txt", FileAccess.READ)

var machine_scene = preload("res://scenes/machines/machine.tscn")

var population = {}

var population_rate = {}

var rng = RandomNumberGenerator.new()

var hud # PlanetHUD passed from hud.tscn

signal clicked

signal exited_view

signal purchase_requested

signal machine_take_money_requested

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if randomly_generated_climate:
		generate_random_climate()
	if generate_name:
		planet_name = gen_name()
	fill_population()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$MeshInstance3D.material_override.set_shader_parameter("oxygen", oxygen_level)
	$MeshInstance3D.material_override.set_shader_parameter("water", water_to_land_ratio)

func generate_random_climate():
	temperature_level	 = rng.randf_range(-0.5, 0.5)
	oxygen_level		 = rng.randf_range(0, 1)
	carbon_dioxide_level = rng.randf_range(0, 1)
	water_to_land_ratio	 = rng.randf_range(0, 1)

func get_closest_planets():
	var sorted_planets = get_tree().get_nodes_in_group("planets")
	var to_return = []
	sorted_planets.sort_custom(func(a, b): return (a.position.distance_to(position)) < b.position.distance_to(position))
	for closest_planet in sorted_planets.slice(1, 4):
		$RayCast3D.look_at(closest_planet.position)
		var collider_shape = $RayCast3D.get_collider_shape()
		if collider_shape != null and closest_planet.get_node("MeshInstance3D/StaticBody3D/CollisionShape3D"):
			to_return.append(closest_planet)
	return to_return

func get_connecting_planets():
	var connecting_planets = []
	for line in get_tree().get_nodes_in_group("lines"):
		if line.from_object == self:
			connecting_planets.add(line.to_object)
		if line.to_object == self and not line.from_object in connecting_planets:
			connecting_planets.add(line.from_object)
	return connecting_planets


func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
		emit_signal("clicked", self)

func unlock():
	self.purchased = true
	$MeshInstance3D.material_overlay.albedo_color.a = 1
	hud.unlock()

# Fills up the "population" array
func fill_population():
	for tribe in get_tree().get_nodes_in_group("tribes"):
		population[tribe.name] = 0
		population_rate[tribe.name] = 0

func get_population_rate(tribe):
	var x = (tribe.get_climate_similarity(self) - climate_similarity_threshold) * (1 - climate_similarity_threshold)
	var rate = (pow(x, population_rate_gradient) if x > 0 else -pow(-x, population_rate_gradient))
	return rate if rate > 0.05 else 0

func update_population():
	for tribe in get_tree().get_nodes_in_group("tribes"):
		population_rate[tribe.name] = int(get_population_rate(tribe) * max_population_rate)
		if population[tribe.name] + population_rate[tribe.name] >= 0 \
			and (get_population_count() + population_rate[tribe.name]) <= max_population:
			population[tribe.name] += population_rate[tribe.name]

func get_population_count():
	var count = 0
	for tribe in population:
		count += population[tribe]
	return count

func gen_name():
	var possible_names = names_file.get_as_text().split("\n")
	var generated_name = possible_names[rng.randi_range(0, possible_names.size() - 1)].strip_edges()
	# Checks to see if the name is blank (for some reason???)
	if generated_name.length() <= 0: return gen_name()
	# Checks to see if the name doesn't already exist
	for planet in get_tree().get_nodes_in_group("planets"):
		if planet != self and planet.planet_name == generated_name:
			return gen_name()
	return generated_name

func _on_planet_hud_exited():
	emit_signal("exited_view", self)

func _on_planet_hud_purchase_pressed():
	emit_signal("purchase_requested", self)

func set_temperature_level(value):
	temperature_level = clamp(value, -0.5, 0.5)

func set_oxygen_level(value):
	oxygen_level = clamp(value, 0, 1)

func set_carbon_dioxide_level(value):
	carbon_dioxide_level = clamp(value, 0, 1)

func set_water_to_land_ratio(value):
	water_to_land_ratio = clamp(value, 0, 1)

func _on_machine_take_money_request(machine, cost):
	emit_signal("machine_take_money_requested", machine, cost)


func _on_planet_hud_request_purchase_machines():
	$MachinePurchaseScreen.update_labels($Machines.get_children())
	$MachinePurchaseScreen.show()


func _on_machine_purchase_screen_request_destroy(machine):
	hud.remove_machine_slider(machine)
	machine.queue_free()


func _on_machine_purchase_screen_request_purchase(machine):
	# TAKE yer MONEY!!!
	emit_signal("machine_take_money_requested", machine, machine.upfront_cost)
	# MAKE a DAMN MACHINE!!!!!
	var clone = machine_scene.instantiate()
	var name_exists = true
	machine.copy_to(clone)
	clone.set_planet(self)
	clone.connect("take_money_request", _on_machine_take_money_request)
	clone.name = machine.name + " "
	while name_exists:
		# check to see if the name exists
		name_exists = false
		for m in $Machines.get_children():
			if m.name == clone.name:
				name_exists = true
		if name_exists:
			clone.name += "I"
	$Machines.add_child(clone)


func _on_static_body_3d_mouse_entered():
	$MeshInstance3D.material_overlay.albedo_color.a += 0.2


func _on_static_body_3d_mouse_exited():
	$MeshInstance3D.material_overlay.albedo_color.a -= 0.2
