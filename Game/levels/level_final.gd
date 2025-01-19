extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Decorations/SmallFrog_01.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_open_cage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		$Decorations/Cage/CageDoor.queue_free()
		$OpenCageArea.queue_free()
