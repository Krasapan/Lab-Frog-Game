extends Node

@onready var player = $"../Player" as Player
@onready var vent = $"../Vent" as RigidBody2D
@onready var player_spawn_point = $PlayerSpawnPoint as Node2D
@onready var start_delay_timer = $StartDelayTimer as Timer

func _ready() -> void:
	player.hide()
	vent.freeze = true
	#player.freeze = true
	await get_tree().process_frame
	player.global_position = player_spawn_point.global_position
	player.show()
	start_delay_timer.start()

func _on_start_delay_timer_timeout() -> void:
	vent.freeze = false
	#player.freeze = false
