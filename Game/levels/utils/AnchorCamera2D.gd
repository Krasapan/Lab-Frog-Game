class_name AnchorCamera2D
extends Camera2D

# Distance to the target in pixels below which the camera slows down.
const SLOW_RADIUS := 300.0

# Maximum speed in pixels per second.
@export var max_speed := 2000.0
# Mass to slow down the camera's movement
@export var mass := 2.0

var _velocity = Vector2.ZERO
# Global position of an anchor area. If it's equal to `Vector2.ZERO`,
# the camera doesn't have an anchor point and follows its owner.
var _anchor_position := Vector2.ZERO
var _target_zoom := 1.0
var _start_global_position : Vector2 = Vector2.ZERO


func _ready() -> void:
	# Setting a node as top-level makes it move independently of its parent.
	_start_global_position = global_position
	enabled = false
	set_as_top_level(true)
	await get_tree().process_frame
	global_position = _start_global_position
	enabled = true
	

# Every frame, we update the camera's zoom level and position.
func _physics_process(delta: float) -> void:
	update_zoom()

	# The camera's target position can either be `_anchor_position` if the value isn't
	# `Vector2.ZERO` or the owner's position. The owner is the root node of the scene in which we
	# instanced and saved the camera. In our demo, it's the Player.
	var target_position: Vector2 = (
		owner.global_position
		if _anchor_position.is_equal_approx(Vector2.ZERO)
		else _anchor_position
	)

	arrive_to(target_position)


# Entering in an `Anchor2D` we receive the anchor object and change our `_anchor_position` and
# `_target_zoom`
func _on_anchor_detector_2d_anchor_detected(anchor: Anchor2D) -> void:
	_anchor_position = anchor.global_position
	_target_zoom = anchor.entered_zoom
	max_speed = anchor.entered_max_speed
	mass = anchor.entered_mass


# Leaving the anchor the zoom return to 1.0 and the camera's center to the player
func _on_anchor_detector_2d_anchor_detached(anchor: Anchor2D) -> void:
	_anchor_position = Vector2.ZERO
	_target_zoom = anchor.exited_zoom
	max_speed = anchor.exited_max_speed
	mass = anchor.exited_mass


# Smoothly update the zoom level using a linear interpolation.
func update_zoom() -> void:
	if not is_equal_approx(zoom.x, _target_zoom):
		# The weight we use considers the delta value to make the animation frame-rate independent.
		var new_zoom_level: float = lerp(
			zoom.x, _target_zoom, 1.0 - pow(0.008, get_physics_process_delta_time())
		)
		zoom = Vector2(new_zoom_level, new_zoom_level)


# Gradually steers the camera to the `target_position` using the arrive steering behavior.
func arrive_to(target_position: Vector2) -> void:
	var distance_to_target := position.distance_to(target_position)
	# We approach the `target_position` at maximum speed, taking the zoom into account, until we
	# get close to the target point.
	var desired_velocity := (target_position - position).normalized() * max_speed * zoom.x
	# If we're close enough to the target, we gradually slow down the camera.
	if distance_to_target < SLOW_RADIUS * zoom.x:
		desired_velocity *= (distance_to_target / (SLOW_RADIUS * zoom.x))

	_velocity += (desired_velocity - _velocity) / mass
	position += _velocity * get_physics_process_delta_time()
