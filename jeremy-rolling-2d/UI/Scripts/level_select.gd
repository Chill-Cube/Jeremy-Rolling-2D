extends Control
var levels : Array

func get_levels() -> Array:
	var dir := DirAccess.open("res://Levels")

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
	
	return levels

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	levels = get_levels()
	
	for i in levels:
		var level = $GridContainer/Template.duplicate()
		level.name = i
		level.text = i
		level.visible = true
		$GridContainer.add_child(level)
		
		var level_data := SaveManager.get_level_data(i)
		
		var children := $GridContainer/Template/Lobster.get_children()

		for v in children.size():
			var ui : Sprite2D = children[v]
			ui.modulate.a = 1.0 if level_data.collectables[v] else 0.3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
