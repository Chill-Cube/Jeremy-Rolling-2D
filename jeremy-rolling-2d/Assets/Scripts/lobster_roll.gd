class_name LobsterRoll
extends Area2D

@export var order := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	if not $BarHarborRevised.visible: return
	$LobsterGet.play()
	$BarHarborRevised.visible = false
	
