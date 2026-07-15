extends Node2D

@export var follow_speed := 0.15
@export var random_strength := 120.0
@export var shake_fade := 5.0

@onready var player: Player = get_parent() as Player

var rng = RandomNumberGenerator.new()
var shake_strength := 0.0

func _ready() -> void:
	player.on_break.connect(_camera_shake)

func _physics_process(_delta: float) -> void:
	var target_pos := player.global_position - player.linear_velocity * 0.05
	
	global_position = global_position.lerp(
		target_pos,
		follow_speed
	) 


func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade * delta)
		$Camera2D.offset = randomOffset()

func _camera_shake():
	shake_strength = random_strength
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength), rng.randf_range(-shake_strength,shake_strength))
