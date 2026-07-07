class_name LobsterRoll
extends Area2D

@export var order := 0
var level : String
var level_data
var original_scale : Vector2

func _ready() -> void:
	original_scale = $BarHarborRevised.scale
	level = owner.scene_file_path.get_file().get_basename()
	level_data = SaveManager.get_level_data(level)
	if level_data.collectables[order - 1] == true:
		$BarHarborRevised.modulate.a = 0.5

var shrinking := false

func _on_body_entered(_body: Node2D) -> void:
	if $BarHarborRevised.scale != original_scale:
		return

	$bite3.play()
	$crunch.play()
	$LobsterGet.play()
	
	$CPUParticles2D.emitting = true
	shrinking = true

	level_data.collectables[order - 1] = true

func _process(delta: float) -> void:
	if shrinking:
		$BarHarborRevised.scale = $BarHarborRevised.scale.lerp(Vector2.ONE * 0.004, 6.0 * delta)
