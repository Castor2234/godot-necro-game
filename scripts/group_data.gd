class_name GroupData
extends RefCounted

enum State { OUTBOUND, LOOTING, RETURNING, DONE }

var id: int = 0
var village_id: StringName = &""
var start: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO
var path_length: float = 1.0
var speed: float = 80.0            # pixels per game second (placeholder)
var state: State = State.OUTBOUND
var progress: float = 0.0          # 0 = at base, 1 = at village
var ticks_left: int = 0            # used while LOOTING
var carried: Dictionary = {}       # loot bundle, e.g. {&"bones": 1000}


func current_position() -> Vector2:
	return start.lerp(target, progress)


func to_dict() -> Dictionary:
	var loot := {}
	for k in carried:
		loot[String(k)] = carried[k]
	return {
		"id": id,
		"village_id": String(village_id),
		"start": [start.x, start.y],
		"target": [target.x, target.y],
		"path_length": path_length,
		"speed": speed,
		"state": int(state),
		"progress": progress,
		"ticks_left": ticks_left,
		"carried": loot,
	}


static func from_dict(d: Dictionary) -> GroupData:
	var g := GroupData.new()
	g.id = int(d.get("id", 0))
	g.village_id = StringName(d.get("village_id", ""))
	var s: Array = d.get("start", [0, 0])
	g.start = Vector2(s[0], s[1])
	var t: Array = d.get("target", [0, 0])
	g.target = Vector2(t[0], t[1])
	g.path_length = float(d.get("path_length", 1.0))
	g.speed = float(d.get("speed", 80.0))
	g.state = int(d.get("state", 0)) as State
	g.progress = float(d.get("progress", 0.0))
	g.ticks_left = int(d.get("ticks_left", 0))
	var loot: Dictionary = d.get("carried", {})
	for k in loot:
		g.carried[StringName(k)] = int(loot[k])
	return g
