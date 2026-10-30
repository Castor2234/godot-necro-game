extends Node2D

const UNIT_GROUP := preload("res://scenes/unit_group/unit_group.tscn")   # adjust the path

@onready var _base: Node2D = $Base
@onready var _groups_root: Node2D = $Groups

var _visuals: Dictionary = {}   # group id -> unit_group node


func _ready() -> void:
	Simulation.group_added.connect(_spawn_visual)
	Simulation.group_removed.connect(_remove_visual)
	Simulation.groups_reloaded.connect(_rebuild_visuals)

	for v in get_tree().get_nodes_in_group("villages"):
		v.input_event.connect(_on_village_input.bind(v))

	_rebuild_visuals()


func _on_village_input(_viewport: Node, event: InputEvent, _shape_idx: int, village: Node2D) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Simulation.send_group(_base.global_position, village.global_position, village.name)


func _rebuild_visuals() -> void:
	for v in _visuals.values():
		v.queue_free()
	_visuals.clear()
	for g in Simulation.groups:
		_spawn_visual(g)


func _spawn_visual(g: GroupData) -> void:
	if _visuals.has(g.id):
		return
	var v := UNIT_GROUP.instantiate()
	_groups_root.add_child(v)
	v.bind(g)
	_visuals[g.id] = v


func _remove_visual(g: GroupData) -> void:
	if _visuals.has(g.id):
		_visuals[g.id].queue_free()
		_visuals.erase(g.id)
