extends Node3D

@export var planets : int = 20

var planet_scene = preload("res://scenes/planet/planet.tscn")

var line_scene = preload("res://scenes/line/line.tscn")

var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate_planets()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# TODO: in the future, voronoi noise
func generate_planets():
	# Generate planets.
	for i in planets:
		var planet = planet_scene.instantiate()
		var pos = generate_planet_position()
		planet.position = Vector3(pos.x, 0, pos.y)
		$Planets.add_child(planet)
	# Initialize planets.
	for planet in get_tree().get_nodes_in_group("planets"):
		for adjacent_planet in planet.get_closest_planets():
			# Checks for duplicates first
			var duplicates = false
			for other in get_tree().get_nodes_in_group("lines"):
				if (other.from_object == adjacent_planet.get_path() and other.to_object == planet.get_path()) or \
				   (other.from_object == planet.get_path() and other.to_object == adjacent_planet.get_path()):
						duplicates = true
			# Now if there isn't any duplicates we will draw a line.
			if duplicates == false:
				var line = line_scene.instantiate()
				line.connect_objects(planet, adjacent_planet)
				line.delete_if_collides = true
				$Planets.add_child(line)


func generate_planet_position() -> Vector2:
	var pos = Vector2(rng.randf_range(-15, 15), rng.randf_range(-15, 15))
	for planet in get_tree().get_nodes_in_group("planets"):
		if Vector3(pos.x, 0, pos.y).distance_to(planet.position) < 3:
			return generate_planet_position()
	return pos
