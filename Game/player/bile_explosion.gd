extends Node2D

@onready var audio_stream_player := $AudioStreamPlayer2D as AudioStreamPlayer2D
@export var explosion_duration : float = 0.1

func _ready() -> void:
	get_tree().create_timer(explosion_duration).connect("timeout", _on_explosion_duration_timeout)

func _on_explosion_duration_timeout():
	hide()

func _on_explode_stream_player_finished() -> void:
	queue_free()
