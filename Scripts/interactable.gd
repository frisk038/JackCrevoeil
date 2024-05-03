extends PhysicsBody3D
class_name Interactable

var interact_hint: String = "Interact"

var on_interact: Callable = Callable(func():
	pass 
)
var on_throw: Callable = Callable(func():
	pass 
)
var on_use: Callable = Callable(func(Vector3, Array):
	pass 
)

func interact():
	on_interact.call()

func throw(vec: Vector3):
	on_throw.call(vec)

func use(vec: Vector3 = Vector3.ZERO, arr:Array = []):
	on_use.call(vec, arr)
