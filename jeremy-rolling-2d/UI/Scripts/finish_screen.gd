class_name Finish
extends CanvasLayer

var level := ""

func _ready() -> void:
	pass # Replace with function body.

func _show_finish(time: String, current_level: String):
	if visible: return
	
	visible = true
	$FinishSFX.play()
	
	level = current_level
	print(current_level)
	
	$Time.text = "Time: " + time 

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/"+level+".tscn")
