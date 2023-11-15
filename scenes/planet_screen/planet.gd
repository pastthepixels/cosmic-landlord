extends Node3D

var adjacent_planets = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_adjacent_planets():
	var sorted_planets = get_tree().get_nodes_in_group("planets")
	var to_return = []
	sorted_planets.sort_custom(func(a, b): return (a.position.distance_to(position)) < b.position.distance_to(position))
	for closest_planet in sorted_planets.slice(1, 4):
		$RayCast3D.look_at(closest_planet.position)
		var collider_shape = $RayCast3D.get_collider_shape()
		if collider_shape != null and closest_planet.get_node("MeshInstance3D/StaticBody3D/CollisionShape3D"):
			to_return.append(closest_planet)
	return to_return

func cache_adjacent_planets():
	adjacent_planets = get_adjacent_planets()
