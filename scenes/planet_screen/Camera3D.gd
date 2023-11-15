extends Camera3D

@export var speed : float = 50;

@export var movement_threshold = 0.2;

var movement_velocity = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	movement_velocity = movement_velocity.cubic_interpolate(Vector3(), movement_velocity, Vector3(), 0.2)
	position += movement_velocity
	# Mouse panning
	var mouse_pos_normalized = Vector2(get_viewport().get_mouse_position()) / Vector2(get_viewport().size)
	# If mouse_pos_normalised is on one of the edges of the screen
	if mouse_pos_normalized.y > (1 - movement_threshold) or \
		mouse_pos_normalized.y < (movement_threshold) or \
		mouse_pos_normalized.x > (1 - movement_threshold) or \
		mouse_pos_normalized.x < (movement_threshold):
		var amount = (mouse_pos_normalized - Vector2(0.5, 0.5)) * speed * delta
		movement_velocity.z = amount.y
		movement_velocity.x = amount.x
