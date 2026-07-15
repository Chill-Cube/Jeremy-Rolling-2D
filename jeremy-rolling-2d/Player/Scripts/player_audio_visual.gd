extends Node2D

@onready var player: Player = get_parent() as Player

@onready var Trail := get_parent().get_node("Trail")
@onready var Explosion := $Explosion
@onready var JumpSFX := get_parent().get_node("jump")
@onready var BoingSFX := get_parent().get_node("boing")
@onready var RollingSFX := get_parent().get_node("Rolling")
@onready var FallingSFX := get_parent().get_node("falling")
@onready var InputNode := get_parent().get_node("Input")

var rotate_speed := 300.0


func _ready() -> void:
	player.on_spring.connect(_spring_sfx) 
	InputNode.on_push.connect(_push_fx)



func _process(delta: float) -> void:
	Trail.emitting = true if player.is_grounded() and player.linear_velocity.length() > 500 else false
	Trail.direction.x = -100 if player.linear_velocity.x > 0 else 100
	Trail.position.x = -38.0 if player.linear_velocity.x > 0 else 38.0

	update_visuals(delta)

func update_visuals(delta) -> void:
	var airborne := !player.is_grounded()

	rotation += (player.linear_velocity.x / rotate_speed) * delta

	var speed = player.linear_velocity.length()

	if airborne and speed > 0.0:
		RollingSFX.stop()
		if not FallingSFX.playing:
			FallingSFX.play()
	else:
		FallingSFX.stop()

		if speed > 20.0:
			if not RollingSFX.playing:
				RollingSFX.play()
		else:
			RollingSFX.stop()

func _spring_sfx() -> void:
	BoingSFX.play()

func _push_fx() -> void:
	Explosion.emitting = true

	JumpSFX.play()
