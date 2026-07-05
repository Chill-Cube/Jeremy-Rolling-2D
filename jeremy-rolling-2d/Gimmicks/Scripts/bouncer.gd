extends Area2D

@export var bounce_force := 500.0

func _ready() -> void:
	add_to_group("bouncer")

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	var normal = ($RayCast2D.to_global($RayCast2D.target_position) - $RayCast2D.global_position).normalized()
	body._spring(normal, bounce_force)
