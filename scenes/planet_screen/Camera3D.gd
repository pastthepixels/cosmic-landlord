extends SpringArm3D

@export var speed : float = 50;

@export var movement_threshold = 0.2;

@export var max_zoom : int = 10

@export var enable_mouse_controls : bool = true

var _use_mouse_controls = true

var _is_mouse_down = false

var _last_mouse_position


# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera3D/PanArea.position = Vector3()
	$Camera3D/PanArea.rotation = Vector3()

func _mouse_input(event):
	if event is InputEventMouseButton and enable_mouse_controls:
		# Scrolling up
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and spring_length - 1  >= 1:
			spring_length -= 1
		# Scrolling down
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and spring_length + 1 <= max_zoom:
			spring_length += 1
		# Panning
		if (not _is_mouse_down) and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_is_mouse_down = true
			_last_mouse_position = project_3d(event.position)
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			_is_mouse_down = false
	if event is InputEventMouseMotion and _is_mouse_down and enable_mouse_controls:
		var position_3d = project_3d(event.position)
		position.x += _last_mouse_position.x - position_3d.x
		position.z += _last_mouse_position.z - position_3d.z

func _notification(notif):
	match notif:
		NOTIFICATION_WM_MOUSE_EXIT:
			_use_mouse_controls = false
		NOTIFICATION_WM_MOUSE_ENTER:
			_use_mouse_controls = true

# Projects a 2D point to 3D space
func project_3d(point_2d):
	return (Plane(Vector3(0, 1, 0), position.y)).intersects_ray(
		$Camera3D.project_ray_origin(point_2d),
		$Camera3D.project_ray_normal(point_2d)
	)

func reset_pan():
	_is_mouse_down = false
	_last_mouse_position = Vector3()


func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
	_mouse_input(event)
