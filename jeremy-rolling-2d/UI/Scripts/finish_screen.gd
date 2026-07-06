class_name Finish
extends CanvasLayer

var level := ""

func _ready() -> void:
	pass # Replace with function body.
	
func get_next_level(current_level: String) -> String:
	var dir := DirAccess.open("res://Levels")
	if dir == null:
		return ""

	var levels: Array[String] = []

	dir.list_dir_begin()
	while true:
		var file := dir.get_next()
		if file == "":
			break

		if file.ends_with(".tscn"):
			levels.append(file.get_basename())

	dir.list_dir_end()

	levels.sort()

	var index := levels.find(current_level)
	if index == -1 or index == levels.size() - 1:
		return ""

	return levels[index + 1]

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
		
	SaveManager.save_to_file()
	
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
		ui.modulate.a = 1.0 if level_data.collectables[i] else 0.3
	
	$Panel/Time.text = "Time: " + format_time(time) 
	$Panel/BestTime.text = "Best Time: " + format_time(level_data.best_time)

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/"+level+".tscn")

func _on_next_level_pressed() -> void:
	var next_level := get_next_level(level)
	get_tree().change_scene_to_file("res://Levels/%s.tscn" % next_level)
