extends Node2D

@onready var player: Player = get_parent() as Player

@onready var Trail := %Trail
@onready var Explosion := $Explosion
@onready var JumpSFX := %jump
@onready var BoingSFX := %boing
@onready var RollingSFX := %Rolling
@onready var FallingSFX := %falling
@onready var InputNode := %Input

var rotate_speed := 300.0
var last_grounded := true
var last_speed := 0.0
var last_velocity_x := 0.0

func _ready() -> void:
	player.on_spring.connect(_spring_sfx) 
	InputNode.on_push.connect(_push_fx)

func _process(delta: float) -> void:
	var grounded := player.is_grounded()
	var speed := player.linear_velocity.length()
	var velocity_x := player.linear_velocity.x
	var should_update_trail := false

	if grounded != last_grounded or abs(speed - last_speed) > 100.0 or sign(velocity_x) != sign(last_velocity_x):
		should_update_trail = true

	if should_update_trail:
		Trail.emitting = grounded and speed > 500.0 and not InputNode.is_mobile
		Trail.direction.x = -100 if velocity_x > 0 else 100
		Trail.position.x = -38.0 if velocity_x > 0 else 38.0

	last_grounded = grounded
	last_speed = speed
	last_velocity_x = velocity_x

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
	JumpSFX.play()

	if InputNode.is_mobile: return
	Explosion.emitting = true
