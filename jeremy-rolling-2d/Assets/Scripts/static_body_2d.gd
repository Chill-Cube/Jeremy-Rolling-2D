@tool
extends StaticBody2D

@onready var polygon := $Polygon2D
@onready var collision := $CollisionPolygon2D
@onready var line := $Line2D
@onready var notifier := $VisibleOnScreenNotifier2D

func _process(_delta):
	if not Engine.is_editor_hint():
		return
	
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

	# Update visibility notifier bounds
	update_notifier()

func update_collision() -> void:
	collision.polygon = polygon.polygon

func update_notifier() -> void:
	var min_pos = polygon.polygon[0]
	var max_pos = polygon.polygon[0]

	for point in polygon.polygon:
		min_pos.x = min(min_pos.x, point.x)
		min_pos.y = min(min_pos.y, point.y)
		max_pos.x = max(max_pos.x, point.x)
		max_pos.y = max(max_pos.y, point.y)

	var margin := 12.0

	notifier.transform = polygon.transform
	notifier.rect = Rect2(
		min_pos + Vector2(margin, margin),
		(max_pos - min_pos) - Vector2(margin * 2, margin * 2)
	)
