extends MeshInstance3D

@export_range(0.01, 0.2) var radius : float = 0.01

@export var delete_if_collides : bool = false

@export_category("Connecting points")
@export var from : Vector3
@export var to : Vector3
@export_category("Connecting objects (overrides points)")
@export var from_object : NodePath
@export var to_object : NodePath


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_mesh()
	generate_area()
	# Wait until the area has been registered to exist...
	await get_tree().process_frame
	# Plantes are bodies on layer 2 -- the only layer between 2 and 3 there are bodies
	# If a line overlaps a body, DELETE it
	if $Area3D.has_overlapping_bodies():
		queue_free()
		return
	# If two lines intersect, remove the longer line.
	for line in get_tree().get_nodes_in_group("lines"):
		if $Area3D.overlaps_area(line.get_child(0)) and line != self:
			(line if line.mesh.height > self.mesh.height else self).queue_free()



func get_from_position() -> Vector3:
	return get_node(from_object).global_position if has_node(from_object) else from

func get_to_position() -> Vector3:
	return get_node(to_object).global_position if has_node(from_object) else to

# Converts from_position and to_position to Vector2 and then gets the angle between them.
func get_angle_2d():
	return Vector2(get_from_position().x, get_from_position().z).angle_to_point(
		Vector2(get_to_position().x, get_to_position().z)
		)

func generate_mesh():
	mesh = CylinderMesh.new()
	mesh.height = get_from_position().distance_to(get_to_position())
	mesh.bottom_radius = radius
	mesh.top_radius = radius
	mesh.radial_segments = 3
	global_position = (get_from_position() + get_to_position()) / 2
	rotate_z(PI/2)
	rotate_y(PI - get_angle_2d())

func generate_area():
	var shape = CollisionShape3D.new()
	shape.shape = CylinderShape3D.new()
	# TODO: HACK
	shape.shape.height = mesh.height - 2
	shape.shape.radius = radius
	$Area3D.add_child(shape)

func connect_objects(from, to):
	self.from_object = from.get_path()
	self.to_object = to.get_path()

func _on_area_3d_area_entered(area):
	var mat = StandardMaterial3D.new()
	mat.albedo = Color.RED
	material_override = mat
