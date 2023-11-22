extends Node3D

@export var planets : int = 20

@export var tribes : int = 5

var planet_scene = preload("res://scenes/planet/planet.tscn")

var line_scene = preload("res://scenes/line/line.tscn")

var tribe_scene = preload("res://scenes/tribe/tribe.tscn")

var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate_tribes()
	generate_planets()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$DemandHUD.update($Player.money, $PayCycle.time_left / $PayCycle.wait_time)
	# Checks for lose states
	if $Player.money <= 0:
		$GameOverScreen.show()
		get_tree().paused = true

func generate_tribes():
	for i in tribes:
		var tribe = tribe_scene.instantiate()
		$Tribes.add_child(tribe)
	$DemandHUD.initialise()

# TODO: in the future, voronoi noise
func generate_planets():
	# Generate planets.
	for i in planets:
		var planet = planet_scene.instantiate()
		var pos = generate_planet_position()
		planet.position = Vector3(pos.x, 0, pos.y)
		planet.connect("clicked", _on_planet_clicked)
		planet.connect("exited_view", _on_planet_exited_view)
		planet.connect("purchase_requested", _on_planet_purchase_requested)
		planet.connect("machine_take_money_requested", _on_planet_machine_take_money_requested)
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


func is_touching_purchased(planet):
	var purchased_lines_exist = false
	for line in get_tree().get_nodes_in_group("lines"):
			if get_node(line.from_object).purchased or get_node(line.to_object).purchased: purchased_lines_exist = true
			if (line.to_object == planet.get_path() and get_node(line.from_object).purchased) or \
			   (line.from_object == planet.get_path() and get_node(line.to_object).purchased):
				return true
	return false if purchased_lines_exist else true

# Purchasing planets!
func _on_planet_purchase_requested(planet):
	if is_touching_purchased(planet):
		$Player.money -= planet.price
		planet.unlock()
		for line in get_tree().get_nodes_in_group("lines"):
			if line.to_object == planet.get_path() or line.from_object == planet.get_path():
				line.set_color(Color.WHITE)
	elif !is_touching_purchased(planet):
		print("Not touching a planet!")
	# Checks for a win state
	if $Player.money > 0:
		var all_planets_purchased = true
		for p in get_tree().get_nodes_in_group("planets"):
			if p.purchased == false:
				all_planets_purchased = false
		if all_planets_purchased:
			$GameWinScreen.show()
			get_tree().paused = true

func _on_planet_clicked(planet):
	if $SpringArm3D.enable_mouse_controls == false: return
	# Stop moving the spring arm and disable moving it
	$SpringArm3D.reset_pan()
	$SpringArm3D.enable_mouse_controls = false
	# Zoom into the planet
	var tween = get_tree().create_tween()
	tween.tween_property($SpringArm3D, "position", planet.position, 0.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property($SpringArm3D, "spring_length", 1, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Show controls for the planet
	planet.show_hud()

func _on_planet_exited_view(planet):
	# Re-enable mouse controls/hide planet HUD
	$SpringArm3D.enable_mouse_controls = true
	planet.hide_hud()
	# Move out camera
	var tween = get_tree().create_tween()
	tween.tween_property($SpringArm3D, "spring_length", 10, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_planet_machine_take_money_requested(machine, cost):
	$Player.money -= cost

func _on_pay_cycle_timeout():
	for planet in get_tree().get_nodes_in_group("planets"):
		if planet.purchased:
			for tribe in get_tree().get_nodes_in_group("tribes"):
				$Player.money += planet.population[tribe.name] * tribe.payback
			# also update people
			planet.update_population()
	#print($Player.money)
