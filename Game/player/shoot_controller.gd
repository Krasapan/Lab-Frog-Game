extends Node2D

@export var max_shoot_strength: float = 2000.0
@export var min_shoot_strength: float = 200.0
@export var shoot_charge_step: float = 2.0
var shoot_strength : float = min_shoot_strength

@onready var ability_cooldown := $AbilityCooldown as Timer
@onready var shoot_audio_player := $ShootAudioPlayer as AudioStreamPlayer2D

var bile_bomb := preload("res://player/bile_bomb.tscn")
var velocity: Vector2 = Vector2.ZERO

@export var ability_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !ability_active:
		return
	if ability_cooldown.is_stopped():
		if Input.is_action_pressed("bile_bomb") and !Input.is_action_pressed("grapple"):
			var target = get_global_mouse_position()
			if shoot_strength < max_shoot_strength:
				shoot_strength += shoot_charge_step
				velocity = global_position.direction_to(target) * shoot_strength
		if Input.is_action_just_released("bile_bomb")  and !Input.is_action_pressed("grapple"):
			_launch_projectile(velocity, global_position)
			shoot_strength = min_shoot_strength
			velocity = Vector2.ZERO
			shoot_audio_player.play()
		

func _launch_projectile(impulse_vector: Vector2, impulse_position: Vector2):
	var projectile_instance = bile_bomb.instantiate()
	projectile_instance.global_position = impulse_position
	get_node("../../").add_child(projectile_instance)
	projectile_instance.apply_impulse(impulse_vector)
	ability_cooldown.start()
