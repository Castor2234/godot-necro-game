extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameClock.push_pause(&"settings")

func _exit_tree() -> void:
	GameClock.pop_pause(&"settings")


func _on_back_button_pressed() -> void:
	SceneRouter.go_back()
