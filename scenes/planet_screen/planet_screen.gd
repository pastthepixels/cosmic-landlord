extends Node3D

@export var planets : int = 20

var planet_scene = preload("res://scenes/planet/planet.tscn")

var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate_planets()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_planets():
	# Generate planets.
	for i in planets:
		var planet = planet_scene.instantiate()
		var pos = generate_planet_position()
		planet.position = Vector3(pos.x, 0, pos.y)
		$Planets.add_child(planet)
	# Initialize planets.
	for planet in get_tree().get_nodes_in_group("planets"):
		planet.cache_adjacent_planets()
		# TODO: remove and simplify
		for adjacent_planet in planet.get_adjacent_planets():
			var mesh = ImmediateMesh.new()
			mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			mesh.surface_add_vertex(planet.position)
			mesh.surface_add_vertex(adjacent_planet.position)
			mesh.surface_end()
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = mesh
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(1, 0, 0)
			mesh_instance.set_surface_override_material(0, material)
			$Planets.add_child(mesh_instance)


func generate_planet_position() -> Vector2:
	var pos = Vector2(rng.randf_range(-15, 15), rng.randf_range(-15, 15))
	for planet in get_tree().get_nodes_in_group("planets"):
		if Vector3(pos.x, 0, pos.y).distance_to(planet.position) < 3:
			return generate_planet_position()
	return pos
