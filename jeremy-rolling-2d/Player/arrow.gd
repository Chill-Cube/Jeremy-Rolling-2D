extends Sprite2D
@onready var player: Player = get_parent() as Player

var aim_direction := Vector2.RIGHT
var drag_pos := Vector2.ZERO
var dragging := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = player.is_mobile


func update_aim() -> void:
	var dir := get_global_mouse_position() - global_position
	if dragging:
		dir = to_global(drag_pos) - global_position

	if dir.length() > 0.001:
		aim_direction = dir.normalized()

	global_rotation = dir.angle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.push_cooldown_timer > 0.0:
		player.push_cooldown_timer -= delta
	else:
		modulate.a = 1

	update_aim()
