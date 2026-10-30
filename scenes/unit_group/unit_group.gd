extends Area2D

var data: GroupData


func bind(g: GroupData) -> void:
	data = g
	global_position = g.current_position()


func _process(_delta: float) -> void:
	if data == null:
		return
	global_position = data.current_position()
	# Fade while looting so you can see the state change.
	modulate.a = 0.55 if data.state == GroupData.State.LOOTING else 1.0
