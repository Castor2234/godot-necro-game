extends Node
## Autoload: remembers which scene opened Settings so we can go back to it.

const SETTINGS_PATH := "res://scenes/settings/settings_screen.tscn"
const FALLBACK_PATH := "res://scenes/main_menu/main_menu.tscn" # change to your main menu path

var return_path: String = ""


func open_settings(from_path: String) -> void:
	return_path = from_path
	get_tree().change_scene_to_file(SETTINGS_PATH)


func go_back() -> void:
	var target := return_path
	if target.is_empty() or not ResourceLoader.exists(target):
		target = FALLBACK_PATH
	return_path = ""
	get_tree().change_scene_to_file(target)
