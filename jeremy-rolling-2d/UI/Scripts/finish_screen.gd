class_name Finish
extends CanvasLayer

var level := ""

func get_next_level(current_level: String) -> String:
	var index := LevelList.LEVELS.find(current_level)

	if index == -1 or index >= LevelList.LEVELS.size() - 1:
		return ""

	return LevelList.LEVELS[index + 1]

func format_time(total_seconds: float) -> String:
	var minutes := int(total_seconds / 60) % 60
	var seconds := int(total_seconds) % 60
	var milliseconds := int((total_seconds - int(total_seconds)) * 1000)

	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

func update_save(time: float, current_level: String) -> void:
	var level_data := SaveManager.get_level_data(current_level)

	level_data.completed = true

	if time < level_data.best_time:
		level_data.best_time = time

	SaveManager.save_to_file()

func _show_finish(time: float, current_level: String) -> void:
	if visible:
		return

	visible = true
	$Panel/FinishSFX.play()

	$Panel/Panel4.visible = get_next_level(current_level) != ""

	update_save(time, current_level)

	level = current_level
	var level_data := SaveManager.get_level_data(level)

	var children := $Panel/Lobsters.get_children()

	for i in children.size():
		var ui: Sprite2D = children[i]
		ui.modulate.a = 1.0 if level_data.collectables[i] else 0.3
		ui.modulate = ui.modulate * 1 if not level_data.collectables[i] else ui.modulate

	$Panel/Time.text = "Time: " + format_time(time)
	$Panel/BestTime.text = "Best Time: " + format_time(level_data.best_time)

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/%s.tscn" % level)

func _on_next_level_pressed() -> void:
	var next_level := get_next_level(level)
	if next_level != "":
		get_tree().change_scene_to_file("res://Levels/%s.tscn" % next_level)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/menu.tscn")
