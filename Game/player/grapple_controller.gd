extends Node2D

@onready var player := get_parent() as RigidBody2D
@onready var grapple_ray := $GrappleRay as RayCast2D
@onready var rope := $Rope as Line2D
@onready var rope_scan_line := $GrappleRay/RopeScanLine as Line2D
#@onready var ability_cooldown := $AbilityCooldown as Timer

var grappled = false
var flies = false
var grapple_point: Vector2
var grapple_object: RigidBody2D
var target: Vector2 = Vector2.ZERO
var pull_speed: float = 200
var rope_length: float = 0
var rope_default_length: float = 0
var rope_max_length: float = 1000

@export var ability_active: bool = false

func _ready() -> void:
	rope_default_length = grapple_ray.target_position.x
	grapple_ray.target_position.x = 0

func _physics_process(delta: float) -> void:
	if !ability_active:
		return
	if Input.is_action_just_pressed("grapple") and !Input.is_action_pressed("bile_bomb"):
		grapple_ray.look_at(get_global_mouse_position())
		flies = true
		grapple_ray.target_position.x = 0
	if flies:
		_handle_launch(delta)
	if grappled:
		_handle_grapple(delta)

func _handle_launch(delta):
#if ability_cooldown.is_stopped():
	if rope_length < rope_max_length:
		rope_length = rope_length + 10
		rope_scan_line.set_point_position(1, Vector2(rope_length, 0))
		#ability_cooldown.start()
	else:
		rope_length = 0
		rope_scan_line.set_point_position(1, Vector2.ZERO)
		flies = false
		#ability_cooldown.start()
	
	grapple_ray.target_position.x = rope_length
	
	if grapple_ray.is_colliding():
		if grapple_ray.get_collider().get_class() == "RigidBody2D":
			grapple_object = grapple_ray.get_collider()
			grapple_point = grapple_object.global_position
		else:
			grapple_object = null
			grapple_point = grapple_ray.get_collision_point()
		grappled = true
		flies = false
		rope_length = 0
		rope_scan_line.set_point_position(1, Vector2.ZERO)
		grapple_ray.target_position.x = 0

func _handle_grapple(delta):
	if !Input.is_action_pressed("grapple"):
		grappled = false
		rope.set_point_position(1, Vector2.ZERO)
		return
	
	if grapple_object:
		target = grapple_object.global_position
	else:
		target = grapple_point
	
	rope.set_point_position(1, to_local(target))
	
	var player_mass = player.mass
	var object_mass = grapple_object.mass if grapple_object else 0
	var total_mass = player_mass + object_mass
	
	#player.apply_impulse(target_dir * target_dist, Vector2.ZERO)
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	var player_pull_force = (player_mass / total_mass) * pull_speed
	var object_pull_force = (object_mass / total_mass) * pull_speed if grapple_object else 0
	
	player.apply_impulse(target_dir * player_pull_force * target_dist * delta, Vector2.ZERO)
	
	if grapple_object:
		var object_to_player_dir = grapple_object.global_position.direction_to(player.global_position)
		#grapple_object.apply_impulse(object_to_player_dir * object_pull_force * target_dist * delta, Vector2(100, 100))
		grapple_object.apply_impulse(object_to_player_dir * object_pull_force * target_dist * delta, Vector2.ZERO)
