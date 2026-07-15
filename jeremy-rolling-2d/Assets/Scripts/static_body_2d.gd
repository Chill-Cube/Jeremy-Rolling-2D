@tool
extends StaticBody2D

@onready var polygon := $Polygon2D
@onready var collision := $CollisionPolygon2D
@onready var line := $Line2D

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
	
	var target_collision = get_parent().get_node_or_null("CollisionPolygon2D")

	if target_collision != null:
		var growth_margin: float = 100.0

		var enlarged_polygons: Array = Geometry2D.offset_polygon(polygon.polygon, growth_margin)
		
		if enlarged_polygons.size() > 0:
			target_collision.polygon = enlarged_polygons[0] 
		else:
			target_collision.polygon = polygon.polygon
		
		target_collision.global_position = polygon.global_position


func update_collision() -> void:
	collision.polygon = polygon.polygon

func update_notifier() -> void:
	var target_collision = get_node_or_null("VisibleOnScreenNotifier2D")
	
	if target_collision == null: return
	
	var notifier = get_node("VisibleOnScreenNotifier2D")
	
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
