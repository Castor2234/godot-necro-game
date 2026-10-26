class_name Village
extends Area2D

signal stats_changed   # emitted whenever citizens/army change (UI listens)
signal destroyed  

const GROUP := "villages"

@export var data:VillageData

@onready var popul_label:Label = $VillageUI/PowerLabel

enum STATE {POPULATED, DESTROYED}

var current_state:STATE = STATE.POPULATED
var current_population :int
var power:int = current_population * 2


func _ready() -> void:
	add_to_group(GROUP)
	current_population = data.Population
	popul_label.text = str(power)

func take_damage(damage:int) -> void:
	current_population-=damage
	# Остановился тут
	stats_changed.emit()
	if current_population<=0:
		destroy_village()
	

func destroy_village() -> void:
	current_state = STATE.DESTROYED
	destroyed.emit()
	input_pickable = false
	modulate = Color(0.5, 0.5, 0.5)
		
	
