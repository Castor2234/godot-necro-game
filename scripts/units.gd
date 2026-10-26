class_name Units
extends RefCounted

# Stored units are 1/1000 of what the player sees:
#   blood          stored in millilitres, shown in litres
#   bones, flesh   stored in grams, shown in kg
#   soul fragments stored in litres, shown in m³

static func litres(x: float) -> int:
	return roundi(x * 1000.0)

static func kg(x: float) -> int:
	return roundi(x * 1000.0)

static func m3(x: float) -> int:
	return roundi(x * 1000.0)
