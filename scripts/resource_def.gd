class_name ResourceDef
extends Resource

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var unit_label: String = "kg"
@export var units_per_display: int = 1000
@export var decimals: int = 2

func format(amount: int) -> String:
	var value := float(amount) / units_per_display
	return "%s %s" % [String.num(value, decimals), unit_label]
