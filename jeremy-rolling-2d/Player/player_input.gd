extends Node

@onready var player: Player = get_parent() as Player

@onready var CameraNode := get_parent().get_node("Node2D")

var simulate_mobile = false
var is_mobile := simulate_mobile or OS.has_feature("web_android") \
	or OS.has_feature("web_ios") \
	or OS.has_feature("ios") \
	or OS.has_feature("android")

const SWIPE_TRAIL = preload("res://Player/swipe_trail.tscn")
@onready var swipe_trail = SWIPE_TRAIL.instantiate()

signal on_push

var dragging := false
var drag_pos := Vector2.ZERO

func start_player():
	if player.freeze and not player.finished_level:
		player.freeze = false

func _input(event: InputEvent) -> void:
	if event is not InputEventScreenDrag and not is_mobile:
		dragging = false

		if event.is_action_pressed("left_click"):
			start_player()

			_reset_swipe_trail()

			if player.can_push(): on_push.emit()


	if is_mobile and event is InputEventScreenTouch and event.pressed:
		_reset_swipe_trail()


	if event is InputEventScreenDrag and is_mobile:
		dragging = true

		drag_pos = event.screen_relative

		swipe_trail.position = (
			(event.position * 8.3)
			+ Vector2(-1546.999 * 3.1, 76.0 * -35)
			+ CameraNode.position
		)

		start_player()
		if player.can_push(): on_push.emit()

func _reset_swipe_trail() -> void:
	if swipe_trail:
		swipe_trail.queue_free()

	swipe_trail = SWIPE_TRAIL.instantiate()
	CameraNode.add_child(swipe_trail)
	swipe_trail.get_node("Trail2D").clear_points()
