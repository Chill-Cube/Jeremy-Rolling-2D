extends Node

@onready var player: Player = get_parent() as Player
@onready var camera_node: Node2D = %Node2D
@onready var arrow: Sprite2D = %Arrow

const SWIPE_TRAIL_SCENE: PackedScene = preload("res://Player/swipe_trail.tscn")
const SWIPE_TRAIL_SCALE := 8.3
const SWIPE_TRAIL_OFFSET := Vector2(-1546.999 * 3.1, 76.0 * -35)

var simulate_mobile := false
var is_mobile := simulate_mobile or OS.has_feature("web_android") \
	or OS.has_feature("web_ios") \
	or OS.has_feature("ios") \
	or OS.has_feature("android")

var active_touch_index := -1
var swipe_trail: Node2D
var drag_pos := Vector2.ZERO
var dragging := false

signal on_push

func _ready():
	_reset_swipe_trail()

func _input(event: InputEvent) -> void:
	if player.finished_level:
		return

	if is_mobile:
		_handle_touch_event(event)
	else:
		_handle_mouse_event(event)

func _handle_mouse_event(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		start_player()
		_reset_swipe_trail()
		if player.can_push():
			emit_signal("on_push")

func _handle_touch_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_process_touch(event)
	elif event is InputEventScreenDrag and event.index == active_touch_index:
		_process_drag(event)

func _process_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and active_touch_index == -1:
		dragging = true
		active_touch_index = event.index
		_reset_swipe_trail()
	elif not event.pressed and event.index == active_touch_index:
		dragging = false
		active_touch_index = -1

func _process_drag(event: InputEventScreenDrag) -> void:
	drag_pos = event.screen_relative
	_update_swipe_trail_position(event.position)
	start_player()
	if player.can_push():
		emit_signal("on_push")

func _update_swipe_trail_position(screen_position: Vector2) -> void:
	swipe_trail.position = screen_position * SWIPE_TRAIL_SCALE \
		+ SWIPE_TRAIL_OFFSET \
		+ camera_node.position

func _reset_swipe_trail() -> void:
	if swipe_trail and swipe_trail.is_inside_tree():
		swipe_trail.queue_free()

	swipe_trail = SWIPE_TRAIL_SCENE.instantiate()
	camera_node.add_child(swipe_trail)
	swipe_trail.get_node("Trail2D").clear_points()

func start_player():
	if player.freeze and not player.finished_level:
		player.freeze = false
	arrow.update_aim()
