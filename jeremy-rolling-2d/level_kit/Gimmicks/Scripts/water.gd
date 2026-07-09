extends Area2D

var bodies = []

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		bodies.append(body)

func _physics_process(delta):
	for body in bodies:
		body.apply_central_impulse((Vector2.UP * 1800) * delta)


func _on_body_exited(body: Node2D) -> void:
	if bodies.has(body):
		bodies.remove_at(bodies.find(body))
