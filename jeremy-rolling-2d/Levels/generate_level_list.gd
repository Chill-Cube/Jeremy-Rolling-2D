@tool
extends EditorScript

func _run() -> void:
	var dir := DirAccess.open("res://Levels")
	if dir == null:
		push_error("Couldn't open res://Levels")
		return

	var levels: Array[String] = []

	dir.list_dir_begin()
	while true:
		var file := dir.get_next()
		if file == "":
			break

		if !dir.current_is_dir() and file.ends_with(".tscn"):
			levels.append(file.get_basename())

	dir.list_dir_end()
	levels.sort()

	var file := FileAccess.open("res://level_list.gd", FileAccess.WRITE)
	if file == null:
		push_error("Couldn't write level_list.gd")
		return

	file.store_line("extends RefCounted")
	file.store_line("class_name LevelList")
	file.store_line("")
	file.store_line("const LEVELS: Array[String] = [")

	for level in levels:
		file.store_line('\t"%s",' % level)

	file.store_line("]")

	file.close()

	print("Generated level_list.gd with %d levels." % levels.size())
