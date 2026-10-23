extends HBoxContainer

@onready var _icon: TextureRect = $Icon
@onready var _amount: Label = $Amount

func setup(def: ResourceDef) -> void:
	_icon.texture = def.icon

func set_amount(text: String) -> void:
	_amount.text = text
