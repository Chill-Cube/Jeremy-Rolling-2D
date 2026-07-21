extends Control
var levels : Array

func _ready() -> void:
	for level_name in LevelList.LEVELS:
		var level := $GridContainer/Template.duplicate()

		level.name = level_name
		level.get_node("Label").text = level_name
		level.visible = true

		$GridContainer.add_child(level)

		var level_data = SaveManager.get_level_data(level_name)
		var children := level.get_node("Lobster").get_children()

		for i in children.size():
			var ui: Sprite2D = children[i]
			ui.modulate = ui.modulate if level_data.collectables[i] else Color(0.0, 0.0, 0.0, 0.384)


func _on_template_pressed() -> void:
	pass # Replace with function body.
