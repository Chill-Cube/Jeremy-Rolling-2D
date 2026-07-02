extends RigidBody2D

@export var move_force := 350.0
@export var click_push_force := 550.0
@export var base_scale := 0.13

@export var stretch_y := 0.23
@export var stretch_x := 0.07
@export var stretch_speed_ref := 4000.0

@export var stretch_speed := 0.01
@export var floor_speed := 0.15

@export var max_pushes := 2
@export var push_cooldown := 1.5


# state
var pushes_left := 0
var cooldown_timer := 0.0

var aim_direction := Vector2.RIGHT
var input_push := false


func _ready():
	pushes_left = max_pushes


func _process(delta: float) -> void:
	_update_cooldown(delta)
	_update_aim()
	_update_visuals(delta)


func _physics_process(delta: float) -> void:
	_sync_visual_root()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_apply_movement(state)
	_apply_push(state)


# INPUT / AIM

func _update_aim():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position

	if dir.length() > 0.001:
		aim_direction = dir.normalized()

	$Arrow.global_rotation = lerp_angle(
		$Arrow.global_rotation,
		dir.angle(),
		0.15
	)


# ABILITY SYSTEM

func _input(event):
	if event.is_action_pressed("left_click"):
		input_push = true


func _update_cooldown(delta):
	if pushes_left == 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			pushes_left = max_pushes


func _apply_push(state: PhysicsDirectBodyState2D):
	if not input_push:
		return

	input_push = false

	if pushes_left <= 0:
		return

	pushes_left -= 1

	if pushes_left == 0:
		cooldown_timer = push_cooldown

	$jump.play()

	var speed_bonus = abs(state.linear_velocity.x) / 10.0

	var is_pointing_up := aim_direction.dot(Vector2.UP) > 0.7
	if is_pointing_up:
		speed_bonus = 0.0

	state.apply_central_impulse(
		aim_direction * (click_push_force + speed_bonus)
	)


# MOVEMENT

func _apply_movement(state: PhysicsDirectBodyState2D):
	var input_vector := Vector2.ZERO
	state.apply_central_force(input_vector * move_force)


# VISUALS

func _update_visuals(delta):
	var airborne := get_contact_count() == 0

	_update_rotation(airborne)
	_update_audio(airborne)
	_update_squash_stretch(airborne)


func _update_rotation(airborne: bool):
	if airborne and linear_velocity.length() > 10.0:
		$Visual.rotation = lerp_angle(
			$Visual.rotation,
			-linear_velocity.angle(),
			0.15
		)
	else:
		$Visual.rotation += linear_velocity.x / 10000.0


func _update_audio(airborne: bool):
	if airborne:
		$Rolling.stop()
		if not $falling.playing:
			$falling.play()
	else:
		$falling.stop()
		if linear_velocity.length() > 5:
			if not $Rolling.playing:
				$Rolling.play()
		else:
			$Rolling.stop()


func _update_squash_stretch(airborne: bool):
	var target_x := base_scale
	var target_y := base_scale

	if airborne:
		var speed_factor = clamp(
			linear_velocity.length() / stretch_speed_ref,
			0.0,
			1.0
		)

		target_x = lerp(base_scale, stretch_x, speed_factor)
		target_y = lerp(base_scale, stretch_y, speed_factor)

	var t := floor_speed if not airborne else stretch_speed

	$Visual/Sprite2D.scale.x = lerp($Visual/Sprite2D.scale.x, target_x, t)
	$Visual/Sprite2D.scale.y = lerp($Visual/Sprite2D.scale.y, target_y, t)


# CAMERA FOLLOW / ROOT SYNC

func _sync_visual_root():
	var target_pos := global_position - linear_velocity * 0.05

	$Node2D.global_position = $Node2D.global_position.lerp(
		target_pos,
		0.15
	)
