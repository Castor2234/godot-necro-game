extends Node

signal tick(tick_number: int)
signal time_changed(total_minutes: int)
signal pause_changed(is_paused: bool)
signal speed_changed(speed: float)

const TICK_SECONDS := 2.0
const MINUTES_PER_TICK := 10
const MAX_TICKS_PER_FRAME := 5

var total_minutes: int = 0
var tick_count: int = 0

var _speed: float = 1.0
var _pause_reasons: Dictionary = {}
var _accum: float = 0.0


# ---------- pause and speed ----------

func push_pause(reason: StringName) -> void:
	var was_paused := is_paused()
	_pause_reasons[reason] = true
	if was_paused != is_paused():
		pause_changed.emit(true)

func pop_pause(reason: StringName) -> void:
	var was_paused := is_paused()
	_pause_reasons.erase(reason)
	if was_paused != is_paused():
		pause_changed.emit(false)

func toggle_user_pause() -> void:
	if _pause_reasons.has(&"user"):
		pop_pause(&"user")
	else:
		push_pause(&"user")

func is_paused() -> bool:
	return not _pause_reasons.is_empty()

func set_speed(s: float) -> void:
	_speed = s
	speed_changed.emit(s)

func get_speed() -> float:
	return _speed

# Movement code multiplies its delta by this.
func get_effective_speed() -> float:
	return 0.0 if is_paused() else _speed


# ---------- ticking ----------

func _process(delta: float) -> void:
	if is_paused():
		return
	_accum += delta * _speed
	var n := 0
	while _accum >= TICK_SECONDS and n < MAX_TICKS_PER_FRAME:
		_accum -= TICK_SECONDS
		_do_tick()
		n += 1
	if n == MAX_TICKS_PER_FRAME:
		_accum = 0.0

func _do_tick() -> void:
	tick_count += 1
	total_minutes += MINUTES_PER_TICK
	
	Debug.log("Elapsed time: %d" %tick_count, "time")
	
	tick.emit(tick_count)
	time_changed.emit(total_minutes)


# ---------- time helpers ----------

@warning_ignore("integer_division")
func get_day() -> int:
	return total_minutes / 1440 + 1

@warning_ignore("integer_division")
func get_hour() -> int:
	return (total_minutes / 60) % 24

func get_minute() -> int:
	return total_minutes % 60

func get_time_string() -> String:
	return "Day %d, %02d:%02d" % [get_day(), get_hour(), get_minute()]


# ---------- saving ----------

func to_dict() -> Dictionary:
	return {
		"total_minutes": total_minutes,
		"tick_count": tick_count,
		"accum": _accum,
		"speed": _speed,
	}

func from_dict(d: Dictionary) -> void:
	total_minutes = int(d.get("total_minutes", 0))
	tick_count = int(d.get("tick_count", 0))
	_accum = float(d.get("accum", 0.0))
	_speed = float(d.get("speed", 1.0))
	time_changed.emit(total_minutes)
	speed_changed.emit(_speed)
