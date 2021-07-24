extends Control

var shopUnitTscn = preload("res://Shop/ShopUnit.tscn")
var slotUnits := []

func _ready():
	slotUnits.resize($Panel.get_child_count())

# attemps to add unit to a bench slot. If theres not room, returns false
func addShopUnit(unit, slot = 0):
	if slotUnits[slot] != null:
		return false
	var slotNode = $Panel.get_child(slot)
	slotUnits[slot] = unit
	slotNode.add_child(unit)
	unit.rect_position = Vector2(4, 4)

# attemps to remove unit from a bench slot. If its not there, returns false
func removeShopUnit(unit):
	var slotIdx = slotUnits.find(unit)
	if slotIdx == -1:
		return false
	
	slotUnits[slotIdx] = null
	var slotNode = $Panel.get_child(slotIdx)
	slotNode.remove_child(unit)

func createShopUnit():
	return shopUnitTscn.instance()
