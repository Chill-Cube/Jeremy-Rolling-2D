extends Area2D

@export var break_speed := 5000.0
var broken := false

func _process(_delta):
	$CollisionPolygon2D.polygon = $StaticBody2D/CollisionPolygon2D.polygon

func _on_body_entered(body: Node2D) -> void:
	if !broken:
		if body is RigidBody2D:
			print(body.linear_velocity.abs().length())
			print(body.linear_velocity)
			if body.linear_velocity.abs().length() >= break_speed:
				broken = true
				get_node("StaticBody2D").queue_free()
				get_node("CPUParticles2D").emitting = true
			else:
				get_node("StaticBody2D").get_node("CollisionShape2D2").disabled = false


func _on_body_exited(body: Node2D) -> void:
	if !broken:
		if body is RigidBody2D:
			get_node("StaticBody2D").get_node("CollisionShape2D2").disabled = true
