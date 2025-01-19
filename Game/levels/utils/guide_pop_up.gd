extends Area2D

@onready var anim_player := $AnimationPlayer as AnimationPlayer

func _ready() -> void:
	modulate = Color(Color.WHITE, 0.0)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		anim_player.play("fade_in")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		anim_player.play("fade_out")
