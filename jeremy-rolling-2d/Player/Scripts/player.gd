class_name Player
extends RigidBody2D

@export var click_push_force := 400.0
@export var max_speed := 15000.0

@export var push_cooldown := 0.6

@export var respawn_time := 0.5

# level info
@onready var start_position := global_position
var level_time := 0.0
var finished_level := false
var started_level := false

# game info
var push_cooldown_timer := 0.0

# states
var contact_count := 0

@onready var Arrow := $Arrow
@onready var Hud := $CanvasLayer2
@onready var Visual := $Visual
@onready var FinishScreen := $CanvasLayer
@onready var InputNode := $Input

# signals

signal on_spring

func _ready() -> void:
	freeze = true
	InputNode.on_push.connect(_apply_push)

func _process(delta: float) -> void:
	if push_cooldown_timer > 0.0:
		push_cooldown_timer -= delta
	if not finished_level and started_level:
		level_time += delta
		Hud._update_timer(level_time)

# checks
func is_grounded() -> bool:
	return contact_count > 0

func _physics_process(_delta: float) -> void:	
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func can_push() -> bool:
	return push_cooldown_timer <= 0.0

# push
func _apply_push() -> void:
	if !can_push():
		return

	push_cooldown_timer = push_cooldown
	
	apply_central_impulse(Arrow.aim_direction * click_push_force)
	
	if not started_level: started_level = true

# interactions
func _spring(normal: Vector2, bounce_force: float) -> void:
	angular_velocity = 0.0
	linear_velocity = linear_velocity.bounce(normal)
	apply_central_impulse(normal * bounce_force)

	on_spring.emit()

func _reset():
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	Visual.rotation = 0

func _death() -> void:
	_reset()

	freeze = true
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", start_position, respawn_time)

func _finish():
	_reset()
	finished_level = true
	
	Hud.visible = false
	FinishScreen._show_finish(level_time, owner.scene_file_path.get_file().get_basename())

# ground checks
func _on_body_entered(_body: Node) -> void:
	contact_count += 1

func _on_body_exited(_body: Node) -> void:
	contact_count -= 1
