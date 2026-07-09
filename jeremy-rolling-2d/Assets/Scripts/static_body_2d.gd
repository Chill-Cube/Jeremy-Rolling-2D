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
	collision.global_position = polygon.global_position

	# Draw outline
	var points := PackedVector2Array(polygon.polygon)
	points.append(polygon.polygon[0])

	line.transform = polygon.transform
	line.points = points

func update_collision() -> void:
	collision.polygon = polygon.polygon


func _on_water_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
