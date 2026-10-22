## battle.gd
## чекнуть
#class_name Battle
#extends Node
#
#signal finished(battle: Battle, players_won: bool)
#
#var village: Village
#var groups: Array = []
#var rng := RandomNumberGenerator.new()
#var timer := Timer.new()
#
#func setup(target: Village) -> void:
	#village = target
	#village.in_combat = true
	#timer.wait_time = 2.0
	#timer.timeout.connect(_on_combat_tick)
	#add_child(timer)
	#timer.start()
#
#func add_group(group) -> void:
	#groups.append(group)           # a later arrival simply joins the fight
#
#func _on_combat_tick() -> void:
	#var fighters := groups.filter(func(g): return g.is_active())
	## ... damage calculation, apply damage, self-preservation (as before) ...
	#_check_end()
#
#func _check_end() -> void:
	#if village.current_state == Village.STATE.DESTROYED:
		#_end(true)
	#elif groups.all(func(g): return not g.is_active()):
		#_wipe_all_groups()
		#_end(false)
#
#func _end(players_won: bool) -> void:
	#village.in_combat = false
	#timer.stop()
	#finished.emit(self, players_won)
	#queue_free()
