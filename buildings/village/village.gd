class_name Village
extends Area2D
# нужно чекнуть похже
# Scene layout expected:
#   Village (Area2D)            <- this script
#   ├─ Sprite2D
#   ├─ CollisionShape2D
#   └─ VillageUI (Node2D)       <- UI script: PowerLabel, SplitBar, SplitLabel

signal stats_changed   # emitted whenever citizens/army change (UI listens)
signal destroyed       # emitted once when the village falls

const GROUP := "villages"

# --- Tuning values ---
const MILITARY_MIN_POP := 1000      # normal villages only get an army from this population up
const NORMAL_ARMY_SHARE := 0.3      # target army share (headcount) for normal villages
const MILITARIZED_ARMY_SHARE := 0.6 # target army share for militarized villages
const CONVERT_RATE := 0.05          # fraction of citizens converted to army per tick
const GROWTH_INTERVAL := 1.0        # seconds between growth ticks
const CITIZEN_RATE := 0.02          # growth contribution per citizen (higher than army)
const ARMY_RATE := 0.005            # growth contribution per army member
const CITIZEN_POWER := 1
const ARMY_POWER := 2
const CITIZEN_ATTACK := 0.5         # citizens fight back, but weaker than soldiers
const ARMY_ATTACK := 2.0

enum STATE { POPULATED, DESTROYED }

@export var data: VillageData       # starting population is read from data.Population
@export var militarized := false
@export var capacity := 5000        # max total population, stops endless growth

var current_state: STATE = STATE.POPULATED
var citizens: int = 0
var army: int = 0
var growth_accum := 0.0
var in_combat := false   # set by the Battle object; pauses growth and conversion

@onready var sprite: Sprite2D = $Sprite2D
@onready var ui: Node = $VillageUI

var power: int:
	get: return citizens * CITIZEN_POWER + army * ARMY_POWER

var army_share: float:   # headcount share, shown on the bar
	get: return army / float(maxi(citizens + army, 1))

var attack_power: float:
	get: return citizens * CITIZEN_ATTACK + army * ARMY_ATTACK


func _ready() -> void:
	add_to_group(GROUP)
	_init_population(data.Population)

	var timer := Timer.new()
	timer.wait_time = GROWTH_INTERVAL
	timer.timeout.connect(_on_growth_tick)
	add_child(timer)
	timer.start()


func _init_population(total: int) -> void:
	var share := 0.0
	if militarized:
		share = MILITARIZED_ARMY_SHARE
	elif total >= MILITARY_MIN_POP:
		share = NORMAL_ARMY_SHARE
	army = roundi(total * share)
	citizens = total - army
	stats_changed.emit()


# Damage is spent on the army first (2 power each), then on citizens (1 power each).
func take_damage(damage: int) -> void:
	if current_state == STATE.DESTROYED:
		return
	var army_loss := mini(army, ceili(damage / float(ARMY_POWER)))
	army -= army_loss
	damage = maxi(damage - army_loss * ARMY_POWER, 0)
	citizens = maxi(citizens - damage, 0)
	stats_changed.emit()
	if power <= 0:
		destroy_village()


func _on_growth_tick() -> void:
	if current_state == STATE.DESTROYED or in_combat:
		return
	var room := maxf(1.0 - float(citizens + army) / capacity, 0.0)
	growth_accum += (CITIZEN_RATE * citizens + ARMY_RATE * army) * room * GROWTH_INTERVAL
	var whole := int(growth_accum)
	growth_accum -= whole
	if whole > 0:
		citizens += whole   # newborns are citizens
		stats_changed.emit()
	_rebalance_military()


# Citizens become army when the army share is below the target.
func _rebalance_military() -> void:
	if not militarized and army == 0 and citizens < MILITARY_MIN_POP:
		return
	var target := MILITARIZED_ARMY_SHARE if militarized else NORMAL_ARMY_SHARE
	if army_share < target:
		var convert := mini(citizens, ceili(citizens * CONVERT_RATE))
		citizens -= convert
		army += convert
		stats_changed.emit()


func destroy_village() -> void:
	current_state = STATE.DESTROYED
	input_pickable = false
	sprite.modulate = Color(0.5, 0.5, 0.5)   # tint only the sprite, not the UI
	ui.queue_free()
	destroyed.emit()
