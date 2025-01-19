@tool
extends StaticBody2D

@onready var ground_polygon := $GroundPolygon as Polygon2D
@onready var lineart := $Lineart as Line2D

func _ready() -> void:
	if not Engine.is_editor_hint():
		var coll := CollisionPolygon2D.new()
		coll.polygon = ground_polygon.polygon
		add_child(coll)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		#if is_instance_valid(ground_polygon.polygon):
		var points := PackedVector2Array(ground_polygon.polygon)
		points.append(ground_polygon.polygon[0])
		lineart.points = points
