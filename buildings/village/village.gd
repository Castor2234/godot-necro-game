class_name Village
extends Area2D

const GROUP := "villages"

@export var data:VillageData

@onready var popul_label:Label = $PopulationText

enum STATE {POPULATED, DESTROYED}

var current_state:STATE = STATE.POPULATED
var current_population :int


func _ready() -> void:
	add_to_group(GROUP)
	current_population = data.Population
	popul_label.text = str(current_population)

func take_damage(damage:int) -> void:
	current_population-=damage
	# Остановился тут
	popul_label.text = str(current_population)
	if current_population<=0:
		destroy_village()
	

func destroy_village() -> void:
	current_state = STATE.DESTROYED
	input_pickable = false
	modulate = Color(0.5, 0.5, 0.5)
		
	
