extends RigidBody2D

@onready var explosion_area := $ExplosionArea as Area2D
@onready var explosion_area_collision_shape := $ExplosionArea/CollisionShape2D as CollisionShape2D
@export var explosion_strength : float = 17500.0
var bile_explosion := preload("res://player/bile_explosion.tscn")

var target_dir : Vector2 = Vector2.ZERO
var target_dist : float = 0.0
var explosion_area_radius : float = 0.0

func _ready() -> void:
	explosion_area_radius = explosion_area_collision_shape.shape.radius

func _on_body_entered(body: Node) -> void:
	_explode()

func _explode():
	explosion_area.monitoring = true
	for entity in explosion_area.get_overlapping_bodies():
		if entity is RigidBody2D:
			target_dir = global_position.direction_to(entity.global_position)
			target_dist = global_position.distance_to(entity.global_position)
			
			#var distance_factor = 1.0 - clamp(target_dist / explosion_area_radius, 0.0, 1.0)
			var distance_factor = 1.5 - clamp(target_dist / explosion_area_radius, 0.0, 1.0)
			var push_force = explosion_strength * distance_factor
			
			var push_vector = target_dir * push_force
			push_vector.x *= 1.2
			
			entity.apply_impulse(push_vector, Vector2.ZERO)
			#print("Pushed: ", str(entity), " with force: ", str(push_force))
	
	_spawn_explosion()
	queue_free()

func _spawn_explosion():
	var explosion_instance = bile_explosion.instantiate()
	explosion_instance.global_position = global_position
	get_node("../../").add_child(explosion_instance)
