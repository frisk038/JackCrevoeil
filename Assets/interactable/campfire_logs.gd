extends "res://Scripts/interactable.gd"

@onready var particle = $GPUParticles3D
@onready var light = $OmniLight3D

var activation_time:float = 5000.0

# Called when the node enters the scene tree for the first time.
func _ready():
	on_interact = Callable(func():
		particle.emitting = !particle.emitting
		light.visible = !light.visible
	)
	interact_hint = "toggle camp fire"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
