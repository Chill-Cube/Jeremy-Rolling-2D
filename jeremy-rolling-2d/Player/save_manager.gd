extends Node

var player_data := PlayerData.new()

func get_level_data(level_name: String) -> LevelData:
	if not player_data.levels.has(level_name):
		player_data.levels[level_name] = LevelData.new()

	return player_data.levels[level_name]

func save_to_file() -> void:
	ResourceSaver.save(player_data, "user://save_game.tres")

func load_from_file() -> void:
	if ResourceLoader.exists("user://save_game.tres"):
		player_data = ResourceLoader.load("user://save_game.tres") as PlayerData
	else:
		player_data = PlayerData.new()
		save_to_file()
	
func _ready() -> void:
	load_from_file()
