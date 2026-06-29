extends RigidBody2D

@export var move_force = 350.0
@export var jump_force = 300.0
@export var click_push_force = 500.0
@export var base_scale = 0.13

@export var stretch_y = 0.23
@export var stretch_x = 0.07
@export var stretch_speed_ref = 4000.0

@export var stretch_speed = 0.01
@export var floor_speed = 0.15

@export var max_pushes = 2
@export var push_cooldown = 1.5

var pushes_left = max_pushes
var cooldown_timer = 0.0

var push_direction = Vector2.ZERO

func _process(delta: float) -> void:
	if pushes_left == 0:
		cooldown_timer -= delta

		if cooldown_timer <= 0:
			pushes_left = max_pushes

	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position
	push_direction = direction.normalized()

	$Arrow.global_rotation = lerp_angle(
		$Arrow.global_rotation,
		direction.angle(),
		0.15
	)

func _physics_process(delta: float) -> void:
	var target_pos = global_position - linear_velocity * 0.05

	$Node2D.global_position = $Node2D.global_position.lerp(
		target_pos,
		0.15
	)

func _integrate_forces(state):
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("right"):
		input_vector.x += 1

	if Input.is_action_pressed("left"):
		input_vector.x -= 1

	if Input.is_action_just_pressed("left_click"):
		if pushes_left > 0:
			pushes_left -= 1

			if pushes_left == 0:
				cooldown_timer = push_cooldown

			$jump.play()

			apply_central_impulse(
				push_direction * click_push_force
			)

	var airborne = state.get_contact_count() == 0

	# Rotate towards movement direction in air
	if airborne and linear_velocity.length() > 10.0:
		$Visual.rotation = lerp_angle(
			$Visual.rotation,
			-linear_velocity.angle(),
			0.15
		)
		$Rolling.stop()
		if not $falling.playing:
			$falling.play()
	else:
		# Rolling on groudnd
		$falling.stop()
		if not $Rolling.playing and linear_velocity.length() > 5:
			$Rolling.play()
		elif linear_velocity.length() < 5:
			$Rolling.stop()
		$Visual.rotation += state.linear_velocity.x / 10000.0

	# Squash/stretch
	var target_x_scale = base_scale
	var target_y_scale = base_scale

	if airborne:
		var speed_factor = clamp(
			linear_velocity.length() / stretch_speed_ref,
			0.0,
			1.0
		)

		target_x_scale = lerp(base_scale, stretch_x, speed_factor)
		target_y_scale = lerp(base_scale, stretch_y, speed_factor)

	$Visual/Sprite2D.scale.x = lerp(
		$Visual/Sprite2D.scale.x,
		target_x_scale,
		floor_speed if not airborne else stretch_speed
	)

	$Visual/Sprite2D.scale.y = lerp(
		$Visual/Sprite2D.scale.y,
		target_y_scale,
		floor_speed if not airborne else stretch_speed
	)

	apply_central_force(input_vector * move_force)
