extends Node

signal game_saved
signal game_loaded

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
	var data := {
		"version": SAVE_VERSION,
		"clock": GameClock.to_dict(),
		"resources": PlayerResources.to_dict(),
		"simulation": Simulation.to_dict(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Save failed, can't open file: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("Game saved")
	game_saved.emit()
	return true


func load_game() -> bool:
	if not has_save():
		print("No save file found")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Load failed, can't open file: %s" % error_string(FileAccess.get_open_error()))
		return false
	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Load failed, save file is damaged")
		return false
	var data: Dictionary = parsed

	if int(data.get("version", 0)) > SAVE_VERSION:
		push_error("Load failed, save is from a newer game version")
		return false
	if typeof(data.get("clock")) != TYPE_DICTIONARY or typeof(data.get("resources")) != TYPE_DICTIONARY:
		push_error("Load failed, save file is missing data")
		return false

	data = _migrate(data)

	GameClock.from_dict(data["clock"])
	PlayerResources.from_dict(data["resources"])
	Simulation.from_dict(data.get("simulation", {}))
	print("Game loaded")
	game_loaded.emit()
	return true


# Upgrades old save formats to the current one. Empty for now.
func _migrate(data: Dictionary) -> Dictionary:
	return data
