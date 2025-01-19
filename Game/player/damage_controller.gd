extends Node

@onready var scene_manager = $"../../../../" as SceneManager
@onready var player = $".." as Player
@onready var death_restart_delay_timer = $DeathRestartDelay as Timer
@export var collision_shape : CollisionShape2D
@export var death_restart_delay : float = 1.0

func _on_player_body_entered(body: Node) -> void:
	if body.is_in_group("Deadly"):
		player.freeze = true
		death_restart_delay_timer.start()

func _on_death_restart_delay_timeout() -> void:
	if is_instance_valid(scene_manager):
		scene_manager.transition_to_restart_current_level()
	else:
		get_tree().reload_current_scene()
	
	
