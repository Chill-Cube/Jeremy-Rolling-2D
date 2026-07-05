class_name LobsterRoll
extends Area2D

@export var order := 0
var level : String
var level_data

func _ready() -> void:
	level = owner.scene_file_path.get_file().get_basename()
	level_data = SaveManager.get_level_data(level)
	if level_data.collectables[order - 1] == true:
		$BarHarborRevised.modulate.a = 0.5

func _on_body_entered(_body: Node2D) -> void:
	if not $BarHarborRevised.visible: return
	$LobsterGet.play()
	$BarHarborRevised.visible = false
	
	level_data.collectables[order - 1] = true
