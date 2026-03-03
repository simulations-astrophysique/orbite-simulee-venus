extends RigidBody3D

var temps : float
@export var periode : float
@export var rayon : float
@export var centreRotation : RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	temps = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = Vector3(
		rayon * cos(2 * PI / periode * temps),
		0.0,
		rayon * sin(2 * PI / periode * temps)
	)
	
	if centreRotation != null:
		position += centreRotation.position
	
	temps += delta
	
	if temps > periode:
		temps -= periode
