extends "res://Scripts/interactable.gd"

@onready var shape: CollisionShape3D = $CollisionShape3D
@onready var needle: Node3D = $needle

@export var target: PhysicsBody3D

var is_picked: bool = false
var originalRotation: Quaternion

func _ready():
	originalRotation = needle.quaternion

	var obj = self
	var casted = (obj as RigidBody3D)
	on_interact = Callable(func():
		print("Picked up compass")
		is_picked = true
		casted.position = Vector3(0, .2, 0)
		casted.rotation = Vector3(1, 0, 0)
		casted.freeze = true
		shape.disabled = true
	)

	on_throw = Callable(func(direction: Vector3):
		shape.disabled = false
		casted.freeze = false
		is_picked = false 
		casted.apply_central_impulse(direction * 5)
	)

	interact_hint = "Pick up compass"

var NORTH = Vector3(0, 0, -24)

func _process(delta):
	if is_picked:
		# point at thing but ignore the compass parent object
		#needle.look_at(target.global_position)
		
		# Calculate the direction to point towards
		var target_direction = (target.global_transform.origin - Vector3(needle.global_transform.origin.x, 0, needle.global_transform.origin.z)).normalized()

		# Create a rotation matrix that points in the target direction
		var target_rotation = Basis.looking_at(target_direction, Vector3(0, 1, 0))

		# working
		needle.global_transform.basis = target_rotation
		needle.rotation.x = 0
		needle.rotation.z = 0

