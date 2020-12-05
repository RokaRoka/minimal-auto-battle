extends Node

# UnitProcessor handles any engagements in combat and unit abilities.
# so yes, FIRE EMBLEM DANCING IS COMBAT

# Stats for unit:
# hp
# str
# def
# mag
# res
# skl
# spd
# lck

# Stats for combat
# damage amt
# hit chance
# crit chance

# Engage in a normal field battle
# Unit1 is assumed to be the initial attacker
# Unit2 will *ALWAYS* be able to counterattack
# Combat goes to end state when 1. either unit dies and/or 2. Both units have attacked
func battle(unit1, unit2):
	#first animation
	unit1.attack(unit2)
	yield(unit1, "attack_done")
	
	#next one
	unit2.attack(unit1)
	yield(unit2, "attack_done")
	
	#resume!
	emit_signal("combat_done")
