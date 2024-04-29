extends CharacterBody3D

@export_category("Player")
@export var mouse_sensitivity:float = 0.1
@export var ray_length:int = 1000
@export var speed:float = 5.0

@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var hand = $Head/Hand
@onready var anim = $AnimationPlayer
@onready var interact_hint:Label = $HUD/HC/Label
@onready var pbar:ProgressBar = $HUD/HC/ProgressBar

var camera_rotation:Vector2 = Vector2.ZERO
var interacting:bool = false
var picked:RigidBody3D = null
var throwing:bool = false
var using:bool = false
var in_reach:Array = Array()
var long_press_start_time = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	_handle_movement(delta)
	
	#region Interact with objects.
	var result: Dictionary = _get_pointed_object()
	if result.size() > 0:
		var collider = result["collider"]
		if collider.collision_layer == 0b10000:
			collider.seen()
			return

		interact_hint.text = collider.interact_hint
		if interacting:
			if collider.collision_layer == 0b0100: # Pickable
				_throw()
				collider.reparent(hand)
				picked = collider
				collider.interact()
			if collider.collision_layer == 0b1000: # Activable
				if collider.activation_time == 0: # Instant activation
					collider.interact()
					interacting = false
				elif long_press_start_time == 0.0: # Long press activation
					long_press_start_time = Time.get_ticks_msec()
					pbar.visible = true
					pbar.value = 0
				elif long_press_start_time > 0.0: # Long press progress
					var hold_time = Time.get_ticks_msec() - long_press_start_time
					pbar.value = (hold_time / collider.activation_time) * 100
					if hold_time > collider.activation_time:
						long_press_start_time = 0.0
						collider.interact()
		else :
			pbar.visible = false
			long_press_start_time = 0.0
			pbar.value = 0
	else:
		interact_hint.text = ""
		interacting = false
		long_press_start_time = 0.0
	#endregion
		
	if throwing:
		_throw()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_rotation -= event.relative * mouse_sensitivity
		camera_rotation.y = clamp(camera_rotation.y, -90, 90)
		head.rotation_degrees = Vector3(camera_rotation.y, camera_rotation.x, 0)

	interacting = Input.is_action_pressed("interact")
	if Input.is_action_just_pressed("throw"):
		throwing = true
	if Input.is_action_just_pressed("use"):
		anim.play("anim")
	
	if Input.is_action_just_pressed("ui_cancel"): get_tree().quit()
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _handle_movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _get_pointed_object() -> Dictionary:
	var mousepos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, 0b0100 | 0b1000 | 0b10000)
	query.collide_with_areas = true
	
	return get_world_3d().direct_space_state.intersect_ray(query)

func _throw():
	if picked != null:
		picked.reparent(get_tree().current_scene)
		picked.throw(-camera.global_transform.basis.z)
		picked = null
	throwing = false

func _use():
	print(in_reach)
	if picked != null:
		picked.use(global_position, in_reach)

func _on_area_3d_body_entered(body):
	print("in<", body.name)
	in_reach.append(body)

func _on_area_3d_body_exited(body):
	print("out>", body.name)
	in_reach.erase(body)
