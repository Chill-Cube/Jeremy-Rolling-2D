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
	$AnimationPlayer.play("hover")
	if level_data.collectables[order - 1] == true:
		$BarHarborRevised.modulate = Color(0.0, 0.0, 0.0, 0.384)

func _on_body_entered(_body: Node2D) -> void:
	if $BarHarborRevised.scale != original_scale:
		return

	$bite3.play()
	$crunch.play()
	$LobsterGet.play()
	
	$CPUParticles2D.emitting = true
	%AnimationPlayer.play("shrink")

	level_data.collectables[order - 1] = true
