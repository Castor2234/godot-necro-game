extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameClock.push_pause(&"main_menu")


func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/location_1/location_1.tscn")

func _on_settings_button_pressed() -> void:
	SceneRouter.open_settings(scene_file_path)

func _exit_tree() -> void:
	GameClock.pop_pause(&"main_menu")
