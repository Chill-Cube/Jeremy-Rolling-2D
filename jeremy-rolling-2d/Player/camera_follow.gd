extends Node2D

@onready var player: Player = get_parent() as Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var target_pos := player.global_position - player.linear_velocity * 0.05
	player.follow_speed = player.death_follow if player.camera_pause else player.normal_follow
	
	global_position = global_position.lerp(
		target_pos,
		player.follow_speed
	) 
