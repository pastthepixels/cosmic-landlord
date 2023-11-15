extends Camera3D

@export var speed : float = 1;

@export var movement_threshold = 0.2;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Mouse panning
	var mouse_pos_normalized = Vector2(get_viewport().get_mouse_position()) / Vector2(get_viewport().size)
	if mouse_pos_normalized.y > (1 - movement_threshold):
		self.position.z += speed * (mouse_pos_normalized.y - (1 - movement_threshold)) * delta
	if mouse_pos_normalized.y < (movement_threshold):
		self.position.z += speed * (mouse_pos_normalized.y - movement_threshold) * delta
	if mouse_pos_normalized.x > (1 - movement_threshold):
		self.position.x += speed * (mouse_pos_normalized.x - (1 - movement_threshold)) * delta
	if mouse_pos_normalized.x < (movement_threshold):
		self.position.x += speed * (mouse_pos_normalized.x - movement_threshold) * delta
