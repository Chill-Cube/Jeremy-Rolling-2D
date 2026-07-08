class_name Player
extends RigidBody2D

@export var click_push_force := 400.0
@export var max_speed := 15000.0

@export var push_cooldown := 0.6

@export var arrow_transparency = 0.7
@export var respawn_time := 0.5

var follow_speed := 0.1
@export var normal_follow := 0.05
@export var death_follow := 0.01

var push_cooldown_timer := 0.0

var aim_direction := Vector2.RIGHT
var input_push := false
var start_position := Vector2.ZERO
var camera_pause := false

var level_time := 0.0
var finished_level := false
var started_level := false

var mobile_first_touch := false

func _ready() -> void:
	freeze = true
	start_position = global_position

func _process(delta: float) -> void:
	if push_cooldown_timer > 0.0:
		push_cooldown_timer -= delta
	else:
		$Arrow.modulate.a = 1
	
	if not finished_level and started_level:
		level_time += delta
		$CanvasLayer2._update_timer(level_time)
		
	$Trail.emitting = true if is_grounded() and linear_velocity.length() > 500 else false
	$Trail.direction.x = -100 if linear_velocity.x > 0 else 100
	$Trail.position.x = -38.0 if linear_velocity.x > 0 else 38.0

	_update_aim()
	_update_visuals()


func is_grounded() -> bool:
	var bodies = get_colliding_bodies()
	if bodies.size() > 0:
		return true
	return false

func _physics_process(_delta: float) -> void:	
	var target_pos := global_position - linear_velocity * 0.05
	follow_speed = death_follow if camera_pause else normal_follow

	$Node2D.global_position = $Node2D.global_position.lerp(
		target_pos,
		follow_speed
	) 
	
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	_apply_push()

func _update_aim() -> void:
	var dir := get_global_mouse_position() - global_position

	if dir.length() > 0.001:
		aim_direction = dir.normalized()

	$Arrow.global_rotation = dir.angle()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		_update_aim()
		if freeze and not finished_level: freeze = false
		input_push = true
	
	if event.is_action_pressed("menu"):
		get_tree().change_scene_to_file("res://UI/menu.tscn")

func _apply_push() -> void:
	if not input_push:
		return

	input_push = false

	if push_cooldown_timer > 0.0:
		return

	push_cooldown_timer = push_cooldown
	$Arrow.modulate.a = arrow_transparency
	$Visual/Explosion.emitting = true

	$jump.play()
	
	apply_central_impulse(aim_direction * click_push_force)
	
	if not started_level: started_level = true

func _spring(normal: Vector2, bounce_force: float) -> void:
	$boing.play()
	angular_velocity = 0.0
	linear_velocity = linear_velocity.bounce(normal)
	apply_central_impulse(normal * bounce_force)

func _reset():
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	$Visual.rotation = 0

func _death() -> void:
	_reset()

	camera_pause = true

	freeze = true
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", start_position, respawn_time)

	tween.finished.connect(func():
		camera_pause = false
	)

func _finish():
	_reset()
	finished_level = true
	
	$CanvasLayer2.visible = false
	$CanvasLayer._show_finish(level_time, owner.scene_file_path.get_file().get_basename())

func _update_visuals() -> void:
	var airborne := get_contact_count() == 0

	$Visual.rotation += linear_velocity.x / 20000.0

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
