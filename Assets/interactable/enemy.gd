extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func attacked(direction: Vector3):
	print("oo")
	apply_central_impulse(-(direction-global_position).normalized() * 5)
