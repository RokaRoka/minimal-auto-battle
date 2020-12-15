extends Panel

func setPlayerUnit(unit):
	$Player/HPBar.value = (float(unit.currHp)/float(unit.hp)) * 100.0
	$Player/HitRate.text = str(unit.getHit())
	$Player/CritRate.text = str(unit.getCrit())

func setEnemyUnit(unit):
	$Enemy/HPBar.value = (float(unit.currHp)/float(unit.hp)) * 100.0
	$Enemy/HitRate.text = str(unit.getHit())
	$Enemy/CritRate.text = str(unit.getCrit())
