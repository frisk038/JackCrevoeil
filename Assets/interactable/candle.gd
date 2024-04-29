extends "res://Scripts/interactable.gd"


@onready var shape: CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var obj = self
	var casted = (obj as RigidBody3D)
	on_interact = Callable(func():
		print("Picked up candle")
		casted.position=Vector3.ZERO
		casted.rotation=Vector3.ZERO
		casted.freeze=true
		shape.disabled=true
	)

	on_throw = Callable(func(direction: Vector3):
		shape.disabled=false
		casted.freeze=false
		casted.apply_central_impulse(direction * 5)
	)

	on_use = Callable(func(vec: Vector3, arr:Array):
		print(arr)
		for a in arr:
			a.attacked(vec)
	)

	interact_hint = "Pick up candle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

