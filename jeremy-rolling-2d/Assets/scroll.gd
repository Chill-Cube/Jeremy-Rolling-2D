extends Sprite2D

# Controls the speed of the scroll in pixels per second
@export var scroll_speed : Vector2 = Vector2(0, 1000)

func _process(delta: float) -> void:
	# Shift the region rect position over time
	region_rect.position += scroll_speed * delta
