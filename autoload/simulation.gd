extends Node

signal group_added(group: GroupData)
signal group_removed(group: GroupData)
signal groups_reloaded

const PLACEHOLDER_LOOT_TICKS := 5

var groups: Array[GroupData] = []
var _next_id: int = 1


func _ready() -> void:
	GameClock.tick.connect(_on_tick)


func send_group(start: Vector2, target: Vector2, village_id: StringName) -> GroupData:
	var g := GroupData.new()
	g.id = _next_id
	_next_id += 1
	g.village_id = village_id
	g.start = start
	g.target = target
	g.path_length = maxf(start.distance_to(target), 1.0)
	groups.append(g)
	group_added.emit(g)
	return g


# Movement is continuous, so it uses _process and the clock's effective speed.
func _process(delta: float) -> void:
	var dt: float = delta * GameClock.get_effective_speed()
	if dt <= 0.0:
		return

	var finished: Array[GroupData] = []
	for g in groups:
		match g.state:
			GroupData.State.OUTBOUND:
				g.progress += g.speed * dt / g.path_length
				if g.progress >= 1.0:
					g.progress = 1.0
					g.state = GroupData.State.LOOTING
					g.ticks_left = PLACEHOLDER_LOOT_TICKS
			GroupData.State.RETURNING:
				g.progress -= g.speed * dt / g.path_length
				if g.progress <= 0.0:
					g.progress = 0.0
					g.state = GroupData.State.DONE
					finished.append(g)

	for g in finished:
		PlayerResources.add_many(g.carried)
		groups.erase(g)
		group_removed.emit(g)


# Looting is counted in ticks.
func _on_tick(_tick_number: int) -> void:
	for g in groups:
		if g.state == GroupData.State.LOOTING:
			g.ticks_left -= 1
			if g.ticks_left <= 0:
				g.carried = {&"bones": Units.kg(1.0)}   # PLACEHOLDER loot
				g.state = GroupData.State.RETURNING


func to_dict() -> Dictionary:
	var list: Array = []
	for g in groups:
		list.append(g.to_dict())
	return {"next_id": _next_id, "groups": list}


func from_dict(d: Dictionary) -> void:
	groups.clear()
	_next_id = int(d.get("next_id", 1))
	for item in d.get("groups", []):
		groups.append(GroupData.from_dict(item))
	groups_reloaded.emit()
