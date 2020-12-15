extends Panel

func _ready():
	hide()

func setStats(unit):
	show()
	$Name.text = unit.name
	$UnitPortrait.texture = unit.texture
	$UnitPortrait.region_rect = unit.region_rect
	
	$HP.text = str("HP: ", unit.hp)
	$Atk.text = str("Atk: ", unit.atk)
	$Def.text = str("Def: ",unit.def)
	$Skl.text = str("Skl: ",unit.skl)
	$Spd.text = str("Spd: ",unit.spd)
	$Lck.text = str("Lck: ",unit.lck)
	$Mov.text = str("Mov: ",unit.mov)
