extends RigidBody2D

@export var move_force := 350.0
@export var click_push_force := 400.0
@export var base_scale := 0.13
@export var max_speed := 15000.0

@export var stretch_y := 0.23
@export var stretch_x := 0.07
@export var stretch_speed_ref := 4000.0

@export var stretch_speed := 0.01
@export var floor_speed := 0.15

@export var max_pushes := 2
@export var push_cooldown := 0.6

var pushes_left := 0
var push_cooldown_timer := 0.0
var was_grounded := false

var aim_direction := Vector2.RIGHT
var input_push := false

func _ready():
	pushes_left = max_pushes
	body_entered.connect(spring)

func _process(delta: float) -> void:
	_update_grounded()
	_update_cooldown(delta)
	_update_aim()
	_update_visuals(delta)

func _physics_process(delta: float) -> void:
	_sync_visual_root()
	
	var v = linear_velocity

	if v.length() > max_speed:
		linear_velocity = v.normalized() * max_speed

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_apply_movement(state)
	_apply_push(state)

# ---------------- INPUT / AIM ----------------

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

func _input(event):
	if event.is_action_pressed("left_click"):
		input_push = true

# ---------------- PUSH SYSTEM ----------------

func _apply_push(state: PhysicsDirectBodyState2D):
	if not input_push:
		return

	input_push = false

	if push_cooldown_timer > 0.0:
		return

	if pushes_left <= 0:
		return

	pushes_left -= 1
	push_cooldown_timer = push_cooldown

	$jump.play()
	_push(aim_direction)

func _update_cooldown(delta: float):
	if push_cooldown_timer > 0.0:
		push_cooldown_timer -= delta

# ---------------- GROUND RESET ----------------

func _update_grounded():
	var grounded := get_contact_count() > 0

	if grounded and not was_grounded:
		pushes_left = max_pushes
		push_cooldown_timer = 0.0

	was_grounded = grounded

# ---------------- MOVEMENT ----------------

func _apply_movement(state: PhysicsDirectBodyState2D):
	var input_vector := Vector2.ZERO
	state.apply_central_force(input_vector * move_force)

func _push(direction: Vector2):
	apply_central_impulse(
		direction * click_push_force
	)

func spring(body):
	if not body.is_in_group("bouncer"):
		return

	var state = PhysicsServer2D.body_get_direct_state(get_rid())
	if state.get_contact_count() == 0:
		return

	var normal = state.get_contact_local_normal(0)

	$boing.play()

	linear_velocity = linear_velocity.bounce(normal)
	apply_central_impulse(normal * click_push_force)

# ---------------- VISUALS ----------------

func _update_visuals(delta: float):
	var airborne := get_contact_count() == 0

	$Visual.rotation += linear_velocity.x / 50000.0
	_update_audio(airborne)

func _update_rotation(airborne: bool):
	if airborne and linear_velocity.length() > 10.0:
		$Visual.rotation = lerp_angle(
			$Visual.rotation,
			-linear_velocity.angle(),
			0.15
		)
	else:
		$Visual.rotation += linear_velocity.x / 50000.0

func _update_audio(airborne: bool):
	if airborne:
		$Rolling.stop()
		if not $falling.playing:
			$falling.play()
	else:
		$falling.stop()

		if linear_velocity.length() > 20.0:
			if not $Rolling.playing:
				$Rolling.play()
		else:
			$Rolling.stop()

func _update_squash_stretch(airborne: bool):
	var target_x := base_scale
	var target_y := base_scale

	if airborne:
		var speed_factor = clamp(linear_velocity.length() / stretch_speed_ref, 0.0, 1.0)

		target_x = lerp(base_scale, stretch_x, speed_factor)
		target_y = lerp(base_scale, stretch_y, speed_factor)

	var t := floor_speed if not airborne else stretch_speed

	$Visual/Sprite2D.scale.x = lerp($Visual/Sprite2D.scale.x, target_x, t)
	$Visual/Sprite2D.scale.y = lerp($Visual/Sprite2D.scale.y, target_y, t)

# ---------------- CAMERA / ROOT SYNC ----------------

func _sync_visual_root():
	var target_pos := global_position - linear_velocity * 0.05

	$Node2D.global_position = $Node2D.global_position.lerp(
		target_pos,
		0.15
	)
