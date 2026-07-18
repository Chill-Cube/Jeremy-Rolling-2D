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
	levels.sort_custom(_natural_less_than)
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

static func _natural_less_than(a: String, b: String) -> bool:
	var regex := RegEx.create_from_string("\\d+|\\D+")
	var chunks_a := regex.search_all(a)
	var chunks_b := regex.search_all(b)
	var count = min(chunks_a.size(), chunks_b.size())
	for i in count:
		var chunk_a: String = chunks_a[i].get_string()
		var chunk_b: String = chunks_b[i].get_string()
		if chunk_a == chunk_b:
			continue
		if chunk_a.is_valid_int() and chunk_b.is_valid_int():
			return chunk_a.to_int() < chunk_b.to_int()
		return chunk_a < chunk_b
	return chunks_a.size() < chunks_b.size()
