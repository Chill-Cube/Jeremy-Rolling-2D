extends Node2D

@onready var player: Player = get_parent() as Player

@onready var Trail := get_parent().get_node("Trail")
@onready var Explosion := $Explosion
@onready var JumpSFX := get_parent().get_node("jump")
@onready var BoingSFX := get_parent().get_node("boing")
@onready var RollingSFX := get_parent().get_node("Rolling")
@onready var FallingSFX := get_parent().get_node("falling")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Trail.emitting = true if player.is_grounded() and player.linear_velocity.length() > 500 else false
	Trail.direction.x = -100 if player.linear_velocity.x > 0 else 100
	Trail.position.x = -38.0 if player.linear_velocity.x > 0 else 38.0

	update_visuals()

func update_visuals() -> void:
	var airborne := !player.is_grounded()

	rotation += player.linear_velocity.x / 20000.0

	if airborne and player.linear_velocity.length():
		RollingSFX.stop()

		if not FallingSFX.playing:
			FallingSFX.play()
	else:
		FallingSFX.stop()

		if player.linear_velocity.length() > 20.0:
			if not RollingSFX.playing:
				RollingSFX.play()
		else:
			RollingSFX.stop()

func _sprinng_sfx() -> void:
	BoingSFX.play()

func push_fx() -> void:
	Explosion.emitting = true

	JumpSFX.play()
