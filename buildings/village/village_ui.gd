extends Node2D

@onready var village: Village = get_parent()
@onready var power_label: Label = $PowerLabel
@onready var bar: ProgressBar = $SplitBar          # min 0, max 1, show_percentage off
@onready var split_label: Label = $SplitLabel

func _ready() -> void:
	# red = army (fill), green = citizens (background)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.8, 0.15, 0.15)
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.2, 0.65, 0.25)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	village.stats_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	power_label.text = str(village.power)
	bar.value = village.army_share
	var army_pct := roundi(village.army_share * 100.0)
	split_label.text = "%d%% / %d%%" % [army_pct, 100 - army_pct]
