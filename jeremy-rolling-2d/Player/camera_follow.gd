extends Node2D

@onready var player: Player = get_parent() as Player

func _ready() -> void:
	pass

@export var follow_speed := 0.15

func _physics_process(_delta: float) -> void:
	var target_pos := player.global_position - player.linear_velocity * 0.05
	
	global_position = global_position.lerp(
		target_pos,
		follow_speed
	) 
