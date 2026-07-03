@tool
extends StaticBody2D

@onready var polygon := $Polygon2D
@onready var collision := $CollisionPolygon2D
@onready var line := $Line2D

func _process(_delta):
	if polygon.polygon.size() < 2:
		return

	# Update collision automatically
	collision.polygon = polygon.polygon

	# Draw outline
	var points := PackedVector2Array(polygon.polygon)
	points.append(polygon.polygon[0])

	line.points = points

func update_collision() -> void:
	collision.polygon = polygon.polygon
