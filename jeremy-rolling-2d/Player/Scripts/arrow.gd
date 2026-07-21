extends Sprite2D
@onready var player: Player = get_parent() as Player
@onready var InputNode := %Input
@export var arrow_transparency = 0.2

var aim_direction := Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = player.get_node("Input").is_mobile == false


func update_aim() -> void:
	var dir := get_global_mouse_position() - player.global_position
	if InputNode.dragging:
		dir = player.to_global(InputNode.drag_pos) - player.global_position

	if dir.length() > 0.001:
		aim_direction = dir.normalized()

	global_rotation = dir.angle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if player.push_cooldown_timer > 0.0:
		modulate.a = arrow_transparency
	else:
		modulate.a = 1

	update_aim()
