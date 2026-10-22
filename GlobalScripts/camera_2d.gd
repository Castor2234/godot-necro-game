extends Camera2D

const MAP_SIZE := Vector2(640, 360)
const ZOOM_MIN := 1.0
const ZOOM_MAX := 10.0
const ZOOM_STEP := 1.2      # multiplier per wheel notch
const ZOOM_SMOOTHING := 15.0 # higher = snappier, lower = floatier

var target_zoom := 1.0
var current_zoom := 1.0
var anchor_mouse := Vector2.ZERO  # screen position of the cursor when zooming
var anchor_world := Vector2.ZERO  # world point that should stay under it

func _ready() -> void:
	global_position = MAP_SIZE / 2.0
	zoom = Vector2.ONE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		_start_zoom(ZOOM_STEP)
	elif event.is_action_pressed("zoom_out"):
		_start_zoom(1.0 / ZOOM_STEP)
	elif event is InputEventMouseMotion and Input.is_action_pressed("pan_drag"):
		global_position -= event.relative / current_zoom
		_clamp_to_map()

func _start_zoom(factor: float) -> void:
	target_zoom = clampf(target_zoom * factor, ZOOM_MIN, ZOOM_MAX)
	# remember which world point is under the cursor right now
	var center := get_viewport_rect().size / 2.0
	anchor_mouse = get_viewport().get_mouse_position()
	anchor_world = global_position + (anchor_mouse - center) / current_zoom

func _process(delta: float) -> void:
	if is_equal_approx(current_zoom, target_zoom):
		return
	# interpolate in log space so zooming feels even at 1x and at 20x
	var weight := 1.0 - exp(-ZOOM_SMOOTHING * delta)
	current_zoom = exp(lerpf(log(current_zoom), log(target_zoom), weight))
	if absf(current_zoom - target_zoom) < 0.001:
		current_zoom = target_zoom
	zoom = Vector2(current_zoom, current_zoom)
	# keep the anchored world point under the cursor
	var center := get_viewport_rect().size / 2.0
	global_position = anchor_world - (anchor_mouse - center) / current_zoom
	_clamp_to_map()

func _clamp_to_map() -> void:
	var half_view := get_viewport_rect().size / current_zoom / 2.0
	global_position = global_position.clamp(half_view, MAP_SIZE - half_view)
