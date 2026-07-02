class_name Bouncer
extends Area2D

@export var debounce_time := 0.5
var bounced := false

func _on_body_entered(body: Node3D) -> void:
	if bounced:
		return
	if not body.has_method("spring"):
		return

	$Jharp294291.play()
	bounced = true
	body.spring()
	_reset_debounce()

func _reset_debounce() -> void:
	await get_tree().create_timer(debounce_time).timeout
	bounced = false
