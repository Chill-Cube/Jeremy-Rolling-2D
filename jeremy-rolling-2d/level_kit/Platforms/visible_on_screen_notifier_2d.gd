extends VisibleOnScreenNotifier2D

func _on_screen_entered() -> void:
	_set_visible(true)

func _on_screen_exited() -> void:
	_set_visible(false)

func _set_visible(value: bool) -> void:
	for child in get_parent().get_children():
		if child == self:
			continue

		if child is CollisionPolygon2D or child is CollisionShape2D:
			child.disabled = not value
		elif child is CanvasItem:
			child.visible = value
