extends Node3D

@export_category("Climate")
@export var randomly_generated_climate : bool = false
# Averge surface temperature, simplified to be a range in -1 to 1 (however 0 == 0 degrees C)
@export_range(-1, 1) var temperature_level : float
# Oxygen level: percentage
@export_range(0, 1) var oxygen_level : float
# Carbon dioxide level: percentage
@export_range(0, 1) var carbon_dioxide_level : float
# Nitrogen level: percentage
#@export_range(0, 1) var nitrogen_level : float
# Percentage of surface occupied by water
@export_range(0, 1) var water_coverage : float # TODO: water to land ratio?
# Percentage of surface occupied by land (TODO: maybe remove this since it = 1 - water_level?)
@export_range(0, 1) var land_coverage : float

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if randomly_generated_climate:
		generate_random_climate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$MeshInstance3D.set_instance_shader_parameter("oxygen", oxygen_level)
	$MeshInstance3D.set_instance_shader_parameter("water", water_coverage)

func generate_random_climate():
	temperature_level	 = rng.randf_range(-1, 1)
	oxygen_level		 = rng.randf_range(0, 1)
	carbon_dioxide_level = rng.randf_range(0, 1)
	water_coverage		 = rng.randf_range(0, 1)
	land_coverage		 = 1 - water_coverage

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
