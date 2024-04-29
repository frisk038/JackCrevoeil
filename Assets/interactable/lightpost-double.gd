extends "res://Scripts/interactable.gd"

@onready var l1 = $Light1 
@onready var l2 = $Light2

var activation_time:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	on_interact = Callable(func():
		print("Picked up candle")
	
		l1.visible = !l1.visible
		l2.visible = !l2.visible
	)

	interact_hint = "Light up the light post"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
