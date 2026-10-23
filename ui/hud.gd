extends CanvasLayer

const RESOURCE_ROW := preload("res://ui/resource_row.tscn")

@onready var _time_label: Label = %TimeLabel
@onready var _pause_button: Button = %PauseButton
@onready var _speed1: Button = %Speed1
@onready var _speed2: Button = %Speed2
@onready var _speed4: Button = %Speed4
@onready var _resource_bar: HBoxContainer = %ResourceBar

var _rows: Dictionary = {}   # id -> ResourceRow


func _ready() -> void:
	# --- resource rows ---
	for id in PlayerResources.defs:
		var row = RESOURCE_ROW.instantiate()
		_resource_bar.add_child(row)              # first into the tree...
		row.setup(PlayerResources.defs[id])       # ...then set it up
		row.set_amount(PlayerResources.format(id))
		_rows[id] = row
	PlayerResources.changed.connect(_on_resource_changed)

	# --- speed buttons (only one can be pressed at a time) ---
	var group := ButtonGroup.new()
	var speeds := {_speed1: 1.0, _speed2: 2.0, _speed4: 4.0}
	for b in speeds:
		b.toggle_mode = true
		b.button_group = group
		b.pressed.connect(GameClock.set_speed.bind(speeds[b]))

	_pause_button.pressed.connect(GameClock.toggle_user_pause)

	# --- listen to the clock ---
	GameClock.time_changed.connect(_on_time_changed)
	GameClock.pause_changed.connect(_on_pause_changed)
	GameClock.speed_changed.connect(_on_speed_changed)

	# --- show current values right away ---
	_on_time_changed(0)
	_on_pause_changed(GameClock.is_paused())
	_on_speed_changed(GameClock.get_speed())


func _on_time_changed(_minutes: int) -> void:
	_time_label.text = GameClock.get_time_string()


func _on_pause_changed(paused: bool) -> void:
	_pause_button.text = "Resume" if paused else "Pause"


func _on_speed_changed(s: float) -> void:
	_speed1.set_pressed_no_signal(is_equal_approx(s, 1.0))
	_speed2.set_pressed_no_signal(is_equal_approx(s, 2.0))
	_speed4.set_pressed_no_signal(is_equal_approx(s, 4.0))


func _on_resource_changed(id: StringName, _new_amount: int, _delta: int) -> void:
	if _rows.has(id):
		_rows[id].set_amount(PlayerResources.format(id))
