extends Area2D

@export var push_force := 1800.0
@export var direction := Vector2.UP


var bodies = []

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		bodies.append(body)

func _physics_process(delta):
	for body in bodies:
		body.apply_central_impulse((direction * push_force) * delta)


func _on_body_exited(body: Node2D) -> void:
	if bodies.has(body):
		bodies.remove_at(bodies.find(body))
