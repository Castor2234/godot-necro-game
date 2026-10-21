extends Node2D

var unit_scene: PackedScene = preload("res://units/units.tscn")

@onready var base: Area2D = $Base


func _ready() -> void:
	for village: Village in get_tree().get_nodes_in_group(Village.GROUP):
		village.input_pickable = true
		# .bind(village) passes the clicked village as the last argument
		village.input_event.connect(_on_village_input_event.bind(village))
		print(village.current_state)
	print("villages found: ", get_tree().get_nodes_in_group(Village.GROUP).size())
	


func _on_village_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, village: Area2D) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		spawn_unit(village)


func spawn_unit(village: Area2D) -> void:
	var unit := unit_scene.instantiate()
	add_child(unit)
	unit.global_position = base.global_position
	unit.setup(base, village)
