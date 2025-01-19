class_name Anchor2D
extends Area2D

#@onready var sprite := $CollisionShape2D/Sprite2D as Sprite2D
@onready var label := $CenterContainer as CenterContainer

# The camera's target zoom level while in this area.
@export var entered_zoom := 1.0
@export var exited_zoom := 1.0
@export var entered_max_speed := 2000.0
@export var exited_max_speed := 2000.0
@export var entered_mass := 2.0
@export var exited_mass := 2.0

func _ready() -> void:
	#sprite.queue_free()
	label.queue_free()
