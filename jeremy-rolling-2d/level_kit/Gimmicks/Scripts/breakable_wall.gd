extends Area2D

@export var break_speed := 5000.0
var broken := false

@onready var AreaCollision := $CollisionPolygon2D
@onready var StaticBodyCollision := $StaticBody2D/CollisionPolygon2D

func _ready() -> void:	
	get_node("Explosion").transform = StaticBodyCollision.transform

func _on_body_entered(body: Node2D) -> void:
	if !broken:
		if body is Player:
			if body.linear_velocity.abs().length() >= break_speed:
				broken = true
				
				
				get_node("StaticBody2D").queue_free()
				get_node("Explosion").emitting = true
				$break.play()
				
				body._on_break.emit()
			else:
				get_node("StaticBody2D").get_node("CollisionPolygon2D").set_deferred("disabled", false)


func _on_body_exited(body: Node2D) -> void:
	if !broken:
		if body is Player:
			get_node("StaticBody2D").get_node("CollisionPolygon2D").set_deferred("disabled", true)
