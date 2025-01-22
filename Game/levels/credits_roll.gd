extends Node2D

@onready var labels := [
	$Control/Label1,
	$Control/Label2,
	$Control/Label3,
	$Control/Label4,
	$Control/Label5,
	$Control/Label6
]

@export var label_hold_time: float
@export var label_tween_time: float

func _ready() -> void:
	loop_credits()

func loop_credits():
	for label in labels:
		var tween = get_tree().create_tween()
		tween.tween_property(label, "modulate", Color.WHITE, label_tween_time)
		await get_tree().create_timer(label_hold_time).timeout
		var fade_tween = get_tree().create_tween()
		fade_tween.tween_property(label, "modulate", Color.TRANSPARENT, label_tween_time / 3)
		await get_tree().create_timer(label_tween_time / 3).timeout
	
	loop_credits()
