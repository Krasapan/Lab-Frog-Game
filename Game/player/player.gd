class_name Player
extends RigidBody2D

@export var stats_small_frog: PlayerStatsResource
@export var stats_big_frog: PlayerStatsResource
var active_stats_resource: PlayerStatsResource

# Rigs
@onready var rig := $Rig as Node2D
@onready var big_frog := $Rig/HopperTransform as Node2D
@onready var small_frog := $Rig/LilHopperTransform as Node2D
@onready var metamorph_timer := $MetamorphTimer as Timer
@onready var acid_boil := $Particles/AcidBoil as GPUParticles2D
@onready var acid_explosion := $Particles/AcidExplosion as GPUParticles2D
@onready var acid_explosion_player := $Particles/VfxBile/AnimationPlayer as AnimationPlayer
@onready var acid_explosion_sprite := $Particles/VfxBile/Sprite2D as Sprite2D

# Rays
@onready var collision_shape := $CollisionShape2D as CollisionShape2D
@onready var rays := $Rays as Node2D
@onready var wallSlideRayL_Top := $Rays/WallSlideRayL_Top as RayCast2D
@onready var wallSlideRayL_Down := $Rays/WallSlideRayL_Down as RayCast2D
@onready var wallSlideRayR_Top := $Rays/WallSlideRayR_Top as RayCast2D
@onready var wallSlideRayR_Down := $Rays/WallSlideRayR_Down as RayCast2D
@onready var floorRayL := $Rays/FloorRayL as RayCast2D
@onready var floorRayR := $Rays/FloorRayR as RayCast2D
@onready var stateLabel := $DebugLabels/State as Label

# Audio
@onready var jump_audio_player := $Audio/JumpStreamPlayer as AudioStreamPlayer2D
@onready var land_audio_player := $Audio/LandStreamPlayer as AudioStreamPlayer2D
@onready var wallslide_audio_player := $Audio/WallslidePlayer as AudioStreamPlayer2D
@onready var mutate_start_player := $Audio/MutateStartPlayer as AudioStreamPlayer2D
@onready var mutate_loop_player := $Audio/MutateLoopPlayer as AudioStreamPlayer2D
@onready var mutate_end_player := $Audio/MutateEndPlayer as AudioStreamPlayer2D

# Animation
@onready var hopper_anim_player := $Rig/HopperTransform/Hopper/AnimationPlayer as AnimationPlayer
@onready var lil_hopper_anim_sprite := $Rig/LilHopperTransform/LilHopperAnimatedSprite as AnimatedSprite2D

# Controllers
@onready var grappleController := $GrappleController as Node2D
@onready var shootController := $ShootController as Node2D

var walk_accel: float = 10000.0
var walk_deaccel: float = 10000.0
var walk_max_velocity: float = 1000.0
var air_accel: float = 3500.0
var air_deaccel: float = 3500.0
var jump_velocity: float = 1600.0
var stop_jump_force: float = 1000.0
const MAX_FLOOR_AIRBORNE_TIME = 0.1
const WALL_SLIDE_SPEED = 200.0
const WALL_SLIDE_GRAVITY = 200.0
const INPUT_BUFFER_TIME = 0.2
const START_BOOST_MULTIPLIER = 1.3

enum FSM_State { ON_FLOOR, IN_AIR, JUMPING, WALL_SLIDING }
var fsm_state = FSM_State.ON_FLOOR

var velocity: Vector2 = Vector2.ZERO
var floor_h_velocity: float = 0.0
var airborne_time: float = 0.0
var jump_buffer_time: float = 0.0
var siding_left : bool = false
var stopping_jump : bool = false
var is_near_left_wall : bool = false
var is_near_right_wall : bool = false
var is_near_floor : bool = false
var can_play_land_snd : bool = true

@export var wallslide_ability_active: bool = false
@export var start_as_big_frog: bool = false
var future_metamoprph_form: int = 0
var metamorph_in_progress: bool = false
@export var current_ability : String = "default"

func _ready() -> void:
	acid_explosion_sprite.modulate = Color(1, 1, 1, 0)
	hopper_anim_player.play("idle_" + current_ability)
	lil_hopper_anim_sprite.play("idle")
	if start_as_big_frog:
		_load_stats(stats_big_frog)
		small_frog.hide()
		big_frog.show()
	else:
		become_small_frog()





func enable_wallslide_ability():
	wallslide_ability_active = true
	current_ability = "ability1"
	var tween = get_tree().create_tween()
	tween.tween_property(rig, "modulate", Color.WHITE, 2)

func enable_grapple_ability():
	grappleController.ability_active = true
	current_ability = "ability2"
	var tween = get_tree().create_tween()
	tween.tween_property(rig, "modulate", Color.WHITE, 2)

func enable_shoot_ability():
	shootController.ability_active = true
	current_ability = "ability3"
	var tween = get_tree().create_tween()
	tween.tween_property(rig, "modulate", Color.WHITE, 2)





func _load_stats(active_stats_resouce: PlayerStatsResource):
	active_stats_resource = active_stats_resouce
	if is_instance_valid(active_stats_resouce):
		walk_accel = active_stats_resouce.walk_accel
		walk_deaccel = active_stats_resouce.walk_deaccel
		walk_max_velocity = active_stats_resouce.walk_max_velocity
		air_accel = active_stats_resouce.air_accel
		air_deaccel = active_stats_resouce.air_deaccel
		jump_velocity = active_stats_resouce.jump_velocity
		stop_jump_force = active_stats_resouce.stop_jump_force
		mass = active_stats_resouce.mass
		collision_shape.scale = active_stats_resouce.scale
		rig.scale = active_stats_resouce.scale
		rays.scale = active_stats_resouce.scale
	else:
		printerr("\"active_stats_resouce\" is empty. Keeping default stats values.")

func metamorph_start(form: int):
	await get_tree().process_frame
	metamorph_in_progress = true
	hopper_anim_player.stop()
	hopper_anim_player.play("metamorph_" + current_ability)
	lil_hopper_anim_sprite.stop()
	lil_hopper_anim_sprite.play("idle")
	mutate_start_player.play()
	mutate_loop_player.play()
	var tween = get_tree().create_tween()
	tween.tween_property(rig, "modulate", Color8(0, 0, 0, 255), 2)
	metamorph_timer.start()
	#acid_boil.emitting = true
	match form:
		0:
			future_metamoprph_form = 0
		1:
			future_metamoprph_form = 1
		2:
			future_metamoprph_form = 2
		3:
			future_metamoprph_form = 3

func _on_metamorph_timer_timeout() -> void:
	metamorph_in_progress = false
	#acid_boil.emitting = false
	#acid_explosion.emitting = true
	acid_explosion_player.play("ExplodeBile")
	mutate_loop_player.stop()
	mutate_end_player.play()
	match future_metamoprph_form:
		0:
			become_big_frog()
		1:
			enable_wallslide_ability()
		2:
			enable_grapple_ability()
		3:
			enable_shoot_ability()
	

func become_small_frog():
	_load_stats(stats_small_frog)
	small_frog.show()
	big_frog.hide()
	var tween = get_tree().create_tween()
	tween.tween_property(rig, "modulate", Color.WHITE, 2)

func become_big_frog():
	global_position.y -= 100
	_load_stats(stats_big_frog)
	small_frog.hide()
	big_frog.show()
	var tween = get_tree().create_tween()
	tween.tween_property(rig, "modulate", Color.WHITE, 2)




func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	stateLabel.text = str(fsm_state)
	
	velocity = state.get_linear_velocity()
	var step := state.get_step()

	var move_left := Input.is_action_pressed("move_left")
	var move_right := Input.is_action_pressed("move_right")
	var jump := Input.is_action_just_pressed("jump")
	var move_down := Input.is_action_pressed("move_down")
	
	if metamorph_in_progress:
		velocity = Vector2.ZERO
		state.set_linear_velocity(Vector2.ZERO)
		move_left = false
		move_right = false
		jump = false
		move_down = false
	
	if jump:
		jump_buffer_time = INPUT_BUFFER_TIME
	else:
		jump_buffer_time -= step

	velocity.x -= floor_h_velocity
	floor_h_velocity = 0.0

	var found_floor := false
	var floor_index := -1
	for contact_index in state.get_contact_count():
		var collision_normal = state.get_contact_local_normal(contact_index)
		if collision_normal.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = contact_index

	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step

	var on_floor := airborne_time < MAX_FLOOR_AIRBORNE_TIME
	$DebugLabels/TargetVelocity.text = str(on_floor)
	
	is_near_left_wall = wallSlideRayL_Top.is_colliding() and wallSlideRayL_Down.is_colliding()
	is_near_right_wall = wallSlideRayR_Top.is_colliding() and wallSlideRayR_Down.is_colliding()

	if (is_near_left_wall or is_near_right_wall) and velocity.y > 0 and not on_floor:
		if wallslide_ability_active:
			fsm_state = FSM_State.WALL_SLIDING
			if !wallslide_audio_player.playing:
				wallslide_audio_player.play()
	elif not (is_near_left_wall or is_near_right_wall) or on_floor:
		if airborne_time < MAX_FLOOR_AIRBORNE_TIME:
			if can_play_land_snd:
				fsm_state = FSM_State.ON_FLOOR
				land_audio_player.play()
				if wallslide_audio_player.playing:
					wallslide_audio_player.stop()
				can_play_land_snd = false
		else:
			fsm_state = FSM_State.IN_AIR
			if wallslide_audio_player.playing:
				wallslide_audio_player.stop()
	else:
		if wallslide_audio_player.playing:
			wallslide_audio_player.stop()
	
	match fsm_state:
		FSM_State.ON_FLOOR:
			velocity = _handle_on_floor(velocity, step, move_left, move_right, jump, on_floor)

		FSM_State.IN_AIR:
			velocity = _handle_in_air(velocity, step, move_left, move_right, jump, on_floor)

		FSM_State.JUMPING:
			velocity = _handle_jumping(velocity, step, jump)

		FSM_State.WALL_SLIDING:
			velocity = _handle_wall_sliding(velocity, step, move_left, move_right, jump, move_down)
			
	if found_floor:
		floor_h_velocity = state.get_contact_collider_velocity_at_position(floor_index).x
		velocity.x += floor_h_velocity
	
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)

func _handle_on_floor(velocity: Vector2, step: float, move_left: bool, move_right: bool, jump: bool, on_floor: bool) -> Vector2:
	if not on_floor:
		fsm_state = FSM_State.IN_AIR
		return velocity

	if move_left and not move_right:
		rig.scale.x = -active_stats_resource.scale.x
		hopper_anim_player.play("run_" + current_ability)
		lil_hopper_anim_sprite.play("walk")
		if velocity.x > -walk_max_velocity:
			velocity.x -= walk_accel * step * (START_BOOST_MULTIPLIER if absf(velocity.x) < 20.0 else 1.0)
	elif move_right and not move_left:
		rig.scale.x = active_stats_resource.scale.x
		hopper_anim_player.play("run_" + current_ability)
		lil_hopper_anim_sprite.play("walk")
		if velocity.x < walk_max_velocity:
			velocity.x += walk_accel * step * (START_BOOST_MULTIPLIER if absf(velocity.x) < 20.0 else 1.0)
	else:
		if !metamorph_in_progress:
			hopper_anim_player.play("idle_" + current_ability)
			lil_hopper_anim_sprite.play("idle")
		var xv := absf(velocity.x)
		xv -= walk_deaccel * step
		if xv < 0:
			xv = 0
		velocity.x = signf(velocity.x) * xv

	# Jump logic
	if jump or jump_buffer_time > 0.0:
		velocity.y = -jump_velocity
		jump_buffer_time = 0.0
		fsm_state = FSM_State.JUMPING
		jump_audio_player.play()

	return velocity

func _handle_in_air(velocity: Vector2, step: float, move_left: bool, move_right: bool, jump: bool, on_floor: bool) -> Vector2:
	can_play_land_snd = true

	if move_left and not move_right:
		if velocity.x > -walk_max_velocity:
			velocity.x -= air_accel * step
	elif move_right and not move_left:
		if velocity.x < walk_max_velocity:
			velocity.x += air_accel * step
	else:
		var xv := absf(velocity.x)
		xv -= air_deaccel * step
		if xv < 0:
			xv = 0
		velocity.x = signf(velocity.x) * xv
	
	if velocity.y > 0:
		hopper_anim_player.play("fall_" + current_ability)
		lil_hopper_anim_sprite.play("fall")
	elif velocity.y < 0:
		hopper_anim_player.play("jump_" + current_ability)
		lil_hopper_anim_sprite.play("jump")

	return velocity

func _handle_jumping(velocity: Vector2, step: float, jump: bool) -> Vector2:
	var move_left := Input.is_action_pressed("move_left")
	var move_right := Input.is_action_pressed("move_right")
	if move_left and not move_right:
		if velocity.x > -walk_max_velocity:
			velocity.x -= air_accel * step
	elif move_right and not move_left:
		if velocity.x < walk_max_velocity:
			velocity.x += air_accel * step

	if velocity.y > 0:
		fsm_state = FSM_State.IN_AIR
	elif not jump:
		stopping_jump = true

	#if stopping_jump:
		#velocity.y += stop_jump_force * step
	hopper_anim_player.play("jump_" + current_ability)

	return velocity

func _handle_wall_sliding(velocity: Vector2, step: float, move_left: bool, move_right: bool, jump: bool, move_down: bool) -> Vector2:
	#if fsm_state != FSM_State.WALL_SLIDING:
		#if is_near_left_wall and move_left or is_near_right_wall and move_right:
			#fsm_state = FSM_State.WALL_SLIDING

	var moving_away_from_wall := (is_near_left_wall and move_right) or (is_near_right_wall and move_left)

	if move_down:
		fsm_state = FSM_State.IN_AIR
		return velocity
	
	if moving_away_from_wall:
		if is_near_left_wall:
			velocity.x = walk_max_velocity
		elif is_near_right_wall:
			velocity.x = -walk_max_velocity
		fsm_state = FSM_State.IN_AIR
		return velocity

	if jump:
		if is_near_left_wall:
			velocity.x = walk_max_velocity * 1.2
		elif is_near_right_wall:
			velocity.x = -walk_max_velocity * 1.2
		velocity.y = -jump_velocity * 0.75
		fsm_state = FSM_State.JUMPING
		hopper_anim_player.play("jump_" + current_ability)
		jump_audio_player.play()
		return velocity

	if is_near_left_wall:
		#velocity.x = max(velocity.x, -walk_max_velocity)
		rig.scale.x = active_stats_resource.scale.x
		hopper_anim_player.play("wallslide_" + current_ability)
		velocity.y = WALL_SLIDE_SPEED
	elif is_near_right_wall:
		#velocity.x = min(velocity.x, walk_max_velocity)
		rig.scale.x = -active_stats_resource.scale.x
		hopper_anim_player.play("wallslide_" + current_ability)
		velocity.y = WALL_SLIDE_SPEED

	velocity.y += WALL_SLIDE_GRAVITY * step

	return velocity
