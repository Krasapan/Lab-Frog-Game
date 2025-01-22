extends Node2D

@onready var anim_player := $AnimationPlayer as AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		anim_player.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
