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
@export_range(0, 1) var water_to_land_ratio : float # TODO: water to land ratio?

@export_category("Purchasing")
@export var price : int
@export var purchased : bool

@export_category("Other")
@export var planet_name = ""
@export var generate_name : bool = false

var rng = RandomNumberGenerator.new()

signal clicked

signal exited_view

signal purchase_requested

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if randomly_generated_climate:
		generate_random_climate()
	if generate_name:
		planet_name = gen_name()
	$PlanetHUD.set_up(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$MeshInstance3D.set_instance_shader_parameter("oxygen", oxygen_level)
	$MeshInstance3D.set_instance_shader_parameter("water", water_to_land_ratio)
	$PlanetHUD.update(self)

func generate_random_climate():
	temperature_level	 = rng.randf_range(-1, 1)
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("clicked", self)

func show_hud():
	$PlanetHUD.show()

func hide_hud():
	$PlanetHUD.hide()

func unlock():
	self.purchased = true
	$MeshInstance3D.material_overlay.albedo_color.a = 1
	$PlanetHUD.unlock()

func gen_name():
	var file = FileAccess.open("res://res/planet_names.txt", FileAccess.READ)
	var possible_names = file.get_as_text().split("\n")
	var generated_name = possible_names[rng.randi_range(0, possible_names.size())]
	# Checks to see if the name doesn't already exist
	for planet in get_tree().get_nodes_in_group("planets"):
		if planet.name.strip_edges() == generated_name.strip_edges():
			return gen_name()
	return generated_name

func _on_planet_hud_exited():
	emit_signal("exited_view", self)

func _on_planet_hud_purchase_pressed():
	emit_signal("purchase_requested", self)
