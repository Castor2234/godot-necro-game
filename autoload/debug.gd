extends Node

func _ready() -> void:
	# In a release export this script does nothing at all.
	set_process_unhandled_input(OS.is_debug_build())
	
func log(message:String, category:String = "!"):
	print("[%s] %s" % [category,message])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_add_resources"):
		PlayerResources.add(&"blood", Units.litres(1.0))
		PlayerResources.add(&"bones", Units.kg(2.5))
		PlayerResources.add(&"flesh", Units.kg(1.5))
		PlayerResources.add(&"soul_fragments", Units.m3(0.25))
	elif event.is_action_pressed(&"debug_save"):
		_call_save_manager(&"save_game")
	elif event.is_action_pressed(&"debug_load"):
		_call_save_manager(&"load_game")
	elif event.is_action_pressed(&"debug_reload_scene"):
		get_tree().reload_current_scene()
		print("Scene reloaded")

func _call_save_manager(method: StringName) -> void:
	var manager := get_node_or_null("/root/SaveManager")
	if manager == null:
		print("SaveManager doesn't exist yet (it's built in the next phase)")
		return
	manager.call(method)
