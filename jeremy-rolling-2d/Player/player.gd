class_name Player
extends RigidBody2D

@export var click_push_force := 400.0
@export var max_speed := 15000.0

@export var push_cooldown := 0.6

@export var arrow_transparency = 0.7

var push_cooldown_timer := 0.0

var aim_direction := Vector2.RIGHT
var input_push := false
var start_position := Vector2.ZERO
var camera_pause := false

var level_time := 0.0
var finished_level := false
var started_level := false

func _ready() -> void:
	start_position = global_position
	body_entered.connect(spring)

func _process(delta: float) -> void:
	if push_cooldown_timer > 0.0:
		push_cooldown_timer -= delta
	else:
		$Arrow.modulate.a = 1
	
	if not finished_level and started_level:
		level_time += delta

	_update_aim()
	_update_visuals()

func _physics_process(_delta: float) -> void:
	_sync_visual_root()

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	_apply_push()

func _update_aim() -> void:
	var dir := get_global_mouse_position() - global_position

	if dir.length() > 0.001:
		aim_direction = dir.normalized()

	$Arrow.global_rotation = lerp_angle(
		$Arrow.global_rotation,
		dir.angle(),
		0.15
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		input_push = true

func _apply_push() -> void:
	if not input_push:
		return

	input_push = false

	if push_cooldown_timer > 0.0:
		return

	push_cooldown_timer = push_cooldown
	$Arrow.modulate.a = arrow_transparency

	$jump.play()
	apply_central_impulse(aim_direction * click_push_force)
	
	if not started_level: started_level = true

func spring(body: Node) -> void:
	if not body.is_in_group("bouncer"):
		return

	var state := PhysicsServer2D.body_get_direct_state(get_rid())
	if state.get_contact_count() == 0:
		return

	var normal := state.get_contact_local_normal(0)

	$boing.play()

	linear_velocity = linear_velocity.bounce(normal)
	apply_central_impulse(normal * body.bounce)

func _reset():
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	$Visual.rotation = 0

func _death() -> void:
	_reset()

	camera_pause = true

	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", start_position, 0.25)

	tween.finished.connect(func():
		freeze = false

		await get_tree().create_timer(2.0).timeout
		camera_pause = false
	)

func format_time(total_seconds: float) -> String:
	var minutes: int = int(total_seconds / 60) % 60
	var seconds: int = int(total_seconds) % 60
	var milliseconds: int = int((total_seconds - int(total_seconds)) * 1000)
	
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	# Returns: "01:15:045"

func _finish():
	_reset()
	finished_level = true

	$CanvasLayer._show_finish(format_time(level_time), owner.scene_file_path.get_file().get_basename())

func _update_visuals() -> void:
	var airborne := get_contact_count() == 0

	$Visual.rotation += linear_velocity.x / 50000.0

	if airborne and linear_velocity.length():
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

func _sync_visual_root() -> void:
	var target_pos := global_position - linear_velocity * 0.05
	var follow_speed := 0.15

	if camera_pause:
		follow_speed = 0.02

	$Node2D.global_position = $Node2D.global_position.lerp(
		target_pos,
		follow_speed
	)
