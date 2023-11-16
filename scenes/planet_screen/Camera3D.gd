extends SpringArm3D

@export var speed : float = 50;

@export var movement_threshold = 0.2;

@export var max_zoom : int = 10

@export var enable_mouse_controls : bool = true

var movement_velocity = Vector3()

var _use_mouse_controls = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	movement_velocity = movement_velocity.cubic_interpolate(Vector3(), movement_velocity, Vector3(), 0.2)
	position += movement_velocity
	# Mouse panningt
	var mouse_pos_normalized = Vector2(get_viewport().get_mouse_position()) / Vector2(get_viewport().size)
	# If mouse_pos_normalised is on one of the edges of the screen
	if (mouse_pos_normalized.y > (1 - movement_threshold) or \
		mouse_pos_normalized.y < (movement_threshold) or \
		mouse_pos_normalized.x > (1 - movement_threshold) or \
		mouse_pos_normalized.x < (movement_threshold)) and \
		enable_mouse_controls and _use_mouse_controls:
		var amount = (mouse_pos_normalized - Vector2(0.5, 0.5)) * speed * delta * (spring_length / max_zoom)
		movement_velocity.z = amount.y
		movement_velocity.x = amount.x

func _input(event):
	# Scrolling
	if event is InputEventMouseButton and enable_mouse_controls:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and spring_length - 1  >= 1:
			spring_length -= 1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and spring_length + 1 <= max_zoom:
			spring_length += 1

func _notification(notif):
	match notif:
		NOTIFICATION_WM_MOUSE_EXIT:
			_use_mouse_controls = false
		NOTIFICATION_WM_MOUSE_ENTER:
			_use_mouse_controls = true
