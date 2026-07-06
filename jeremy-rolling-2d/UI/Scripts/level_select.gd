extends Control
var levels : Array

func _ready() -> void:
	for level_name in LevelList.LEVELS:
		var level := $GridContainer/Template.duplicate()

		level.name = level_name
		level.text = level_name
		level.visible = true

		$GridContainer.add_child(level)

		var level_data = SaveManager.get_level_data(level_name)
		var children := level.get_node("Lobster").get_children()

		for i in children.size():
			var ui: Sprite2D = children[i]
			ui.modulate.a = 1.0 if level_data.collectables[i] else 0.3
