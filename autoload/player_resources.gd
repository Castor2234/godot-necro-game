extends Node

signal changed(id: StringName, new_amount: int, delta: int)

const DEFS: Array[ResourceDef] = [
	preload("res://data/resources/blood.tres"),
	preload("res://data/resources/bones.tres"),
	preload("res://data/resources/flesh.tres"),
	preload("res://data/resources/soul_fragments.tres"),
]

var defs: Dictionary = {}       # id -> ResourceDef
var _amounts: Dictionary = {}   # id -> int


func _ready() -> void:
	for d in DEFS:
		defs[d.id] = d
		_amounts[d.id] = 0


func get_amount(id: StringName) -> int:
	return _amounts.get(id, 0)


func format(id: StringName) -> String:
	return defs[id].format(get_amount(id))


func add(id: StringName, amount: int) -> void:
	if amount == 0 or not defs.has(id):
		return
	_amounts[id] = get_amount(id) + amount
	changed.emit(id, _amounts[id], amount)


func add_many(bundle: Dictionary) -> void:
	for id in bundle:
		add(id, bundle[id])


func can_afford(cost: Dictionary) -> bool:
	for id in cost:
		if get_amount(id) < cost[id]:
			return false
	return true


func spend(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for id in cost:
		add(id, -cost[id])
	return true


func to_dict() -> Dictionary:
	var out := {}
	for id in _amounts:
		out[String(id)] = _amounts[id]
	return {"amounts": out}


func from_dict(d: Dictionary) -> void:
	var saved: Dictionary = d.get("amounts", {})
	for id in defs:
		_amounts[id] = int(saved.get(String(id), 0))
		changed.emit(id, _amounts[id], 0)
