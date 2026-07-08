extends CanvasLayer

var level := ""

func format_time(total_seconds: float) -> String:
	var minutes := int(total_seconds / 60) % 60
	var seconds := int(total_seconds) % 60
	var milliseconds := int((total_seconds - int(total_seconds)) * 1000)

	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

func _ready() -> void:
	level = owner.owner.scene_file_path.get_file().get_basename()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/menu.tscn")


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/%s.tscn" % level)
	

func _update_timer(time : float) -> void:
	$Timer/Label.text = format_time(time)
