extends Node

@onready var scene_manager := $"../../../../" as SceneManager
@onready var player := $".." as Player
@onready var death_restart_delay_timer := $DeathRestartDelay as Timer
@onready var explosive_bile_anim := $"../Particles/VfxBile/AnimationPlayer" as AnimationPlayer
@onready var death_stream_player := $"../Audio/DeathStreamPlayer" as AudioStreamPlayer2D

@export var collision_shape : CollisionShape2D
@export var death_restart_delay : float = 1.0

# Ability controllers
@onready var grapple_controller := $"../GrappleController" as Node2D
@onready var shoot_controller := $"../ShootController" as Node2D

func _on_player_body_entered(body: Node) -> void:
	if body.is_in_group("Deadly"):
		player.freeze = true
		grapple_controller.ability_active = false
		shoot_controller.ability_active = false
		grapple_controller.hide()
		shoot_controller.hide()
		player.rig.hide()
		death_stream_player.play()
		explosive_bile_anim.play("ExplodeBile")
		death_restart_delay_timer.start()

func _on_death_restart_delay_timeout() -> void:
	if is_instance_valid(scene_manager):
		scene_manager.transition_to_restart_current_level()
	else:
		get_tree().reload_current_scene()
	
	
