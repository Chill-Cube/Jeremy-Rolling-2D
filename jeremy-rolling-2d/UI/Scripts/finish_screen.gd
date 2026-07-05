class_name Finish
extends CanvasLayer

var level := ""

func _ready() -> void:
	pass # Replace with function body.
	

func format_time(total_seconds: float) -> String:
	var minutes: int = int(total_seconds / 60) % 60
	var seconds: int = int(total_seconds) % 60
	var milliseconds: int = int((total_seconds - int(total_seconds)) * 1000)
	
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

func update_save(time: float, current_level: String):
	var level_data := SaveManager.get_level_data(current_level)
	level_data.completed = true
	if level_data.best_time > time:
		level_data.best_time = time
	
func _show_finish(time: float, current_level: String):
	if visible: return
	
	visible = true
	$Panel/FinishSFX.play()
	
	update_save(time, current_level)
	
	level = current_level
	var level_data := SaveManager.get_level_data(level)
	
	var children := $Panel/Lobsters.get_children()

	for i in children.size():
		var ui : Sprite2D = children[i]
		
		print(ui, i, level_data.collectables[i])
		if level_data.collectables[i] == true:
			ui.visible = true
	
	$Panel/Time.text = "Time: " + format_time(time) 
	$Panel/BestTime.text = "Best Time: " + format_time(level_data.best_time)

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/"+level+".tscn")
