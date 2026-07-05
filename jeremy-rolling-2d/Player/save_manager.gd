extends Node

var player_data := PlayerData.new()

func get_level_data(level_name: String) -> LevelData:
	if not player_data.levels.has(level_name):
		player_data.levels[level_name] = LevelData.new()

	return player_data.levels[level_name]
