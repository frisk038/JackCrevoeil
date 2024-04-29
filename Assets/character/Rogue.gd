extends CharacterBody3D

@export var player: CharacterBody3D = null
var movement_speed: float = 2.5
var rotation_speed: float = 5.0
var movement_target_position: Vector3 = Vector3(-3.0, 0.0, 2.0)
var hiding_distance: float = 10.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var head = $Head

var is_chasing: bool = true

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	seen()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

func _physics_process(delta):
	# Calculate direction to player
	var target_direction = (player.global_position - transform.origin).normalized()
	var target_rotation = atan2(target_direction.x, target_direction.z)
	$Rig.rotation.y = target_rotation
	
	## If player is looking at the enemy, make it go away
	# if is_player_looking_at_enemy():
	# 	return

	# Move towards player
	navigation_agent.set_target_position(player.global_transform.origin)
	var v = (navigation_agent.get_next_path_position() - transform.origin).normalized() * movement_speed * delta
	move_and_collide(v)

func is_player_looking_at_enemy() -> bool:
	# Get direction from player to enemy
	var direction_to_enemy = (transform.origin - player.global_transform.origin).normalized()

	# Get direction player is facing
	var direction_player_facing = -player.head.global_transform.basis.z.normalized()

	# Check if player is looking towards the enemy
	return direction_to_enemy.dot(direction_player_facing) > 0.5

func seen():
	# Calculate a random position in a circle around the player
	var angle = randf_range(180, 360)
	var offset = Vector3(cos(deg_to_rad(angle)), 0, sin(deg_to_rad(angle))) * hiding_distance
	global_transform.origin = player.head.global_transform.origin + offset
