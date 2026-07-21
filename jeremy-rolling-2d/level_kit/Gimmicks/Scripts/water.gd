extends Area2D

@export var push_force := 1800.0
@export var direction := Vector2.UP

var bodies: Array[Node2D] = []

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and not bodies.has(body):
		bodies.append(body)

func _physics_process(delta):
	if bodies.is_empty():
		return

	for i in range(bodies.size() - 1, -1, -1):
		var body: Node2D = bodies[i]
		if not is_instance_valid(body) or not body.is_inside_tree():
			bodies.remove_at(i)
			continue

		body.apply_central_impulse((direction * push_force) * delta)

func _on_body_exited(body: Node2D) -> void:
	if bodies.has(body):
		bodies.erase(body)
