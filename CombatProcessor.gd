extends Node
signal combat_done

onready var combatUI = get_node("/root/Game/UI/Combat")

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
	combatUI.show()
	if unit1.affiliation == "Player":
		combatUI.setPlayerUnit(unit1)
		unit1.connect("damage_taken", combatUI, "setPlayerUnit")
	else:
		combatUI.setEnemyUnit(unit1)
		unit1.connect("damage_taken", combatUI, "setEnemyUnit")
	
	if unit2.affiliation == "Enemy":
		combatUI.setEnemyUnit(unit2)
		unit2.connect("damage_taken", combatUI, "setEnemyUnit")
	else:
		combatUI.setPlayerUnit(unit2)
		unit2.connect("damage_taken", combatUI, "setPlayerUnit")
	
	#first animation
	#unit2.get_node("HealthUI").show()
	unit1.attack(unit2)
	yield(unit1, "attack_done")
	#unit2.get_node("HealthUI").hide()
	
	#next one
	#unit1.get_node("HealthUI").show()
	unit2.attack(unit1)
	yield(unit2, "attack_done")
	#unit1.get_node("HealthUI").hide()
	
	
	if unit1.affiliation == "Player":
		unit1.disconnect("damage_taken", combatUI, "setPlayerUnit")
	else:
		unit1.disconnect("damage_taken", combatUI, "setEnemyUnit")
	
	if unit2.affiliation == "Enemy":
		unit2.disconnect("damage_taken", combatUI, "setEnemyUnit")
	else:
		unit2.disconnect("damage_taken", combatUI, "setPlayerUnit")
	combatUI.hide()
	#resume!
	emit_signal("combat_done")
