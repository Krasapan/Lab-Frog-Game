extends Node2D

@onready var fan_transform := $FanTransform as Node2D

func _process(delta: float) -> void:
	fan_transform.rotation_degrees += 5
	if fan_transform.rotation_degrees >= 360:
		fan_transform.rotation_degrees = 0
