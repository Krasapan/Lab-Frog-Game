extends Node2D

@onready var audio_stream_player := $AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var explosive_bile := $VfxBile as Node2D
@onready var explosive_bile_anim := $VfxBile/AnimationPlayer as AnimationPlayer
@export var explosion_duration : float = 0.1

func _ready() -> void:
	explosive_bile.show()
	explosive_bile_anim.play("ExplodeBile")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
