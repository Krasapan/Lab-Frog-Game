extends RigidBody2D

@onready var hit_sound := $HitSound as AudioStreamPlayer2D

func _on_body_entered(body: Node) -> void:
	hit_sound.play()
