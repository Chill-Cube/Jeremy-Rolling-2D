extends Area2D

func _ready():
	add_to_group("death")

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
		
	body.call_deferred("_death")
