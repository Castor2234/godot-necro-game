class_name CreatureData
extends Resource

enum Size { EXTREMELY_SMALL, VERY_SMALL, SMALL, MEDIUM, LARGE, HUGE, COLOSSAL }
enum Locomotion { TERRESTRIAL, FLYING, AQUATIC, BURROWING }
enum Covering { SKIN, FUR, FEATHERS, SCALES, EXOSKELETON, SHELL }
enum DamageType { PIERCING, SLASHING, BLUDGEONING, POISON }

@export var creature_name: String
@export var size: Size
@export var locomotion: Locomotion
@export var covering: Covering
@export var classifications: Array[StringName]   # &"vermin", &"rodent"
@export var damage_types: Array[DamageType]
@export var traits: Array[CreatureTrait]


# in CreatureData
#const SIZE_HEALTH := [1.0, 3.0, 10.0, 40.0, 200.0, 1000.0, 5000.0]
#
#@export var stat_overrides: Dictionary = {}   # {&"health": 8.0} when you want to hand-tune
#
#func get_base_stat(stat: StringName) -> float:
	#if stat_overrides.has(stat):
		#return stat_overrides[stat]
	#var value := _size_base(stat)
	#value *= _covering_modifier(stat)
	#value *= _locomotion_modifier(stat)
	#for t in traits:
		#value *= t.modifiers.get(stat, 1.0)
	#return value
