extends Node2D

# branched scenes
var unitTscn = preload("res://Unit/Unit.tscn")

onready var grid = $Grid
onready var phaseAnimPlayer = $UI/Phase/AnimationPlayer
onready var prepUI = $UI/PrepMenu
onready var bench = $UI/Bench

var turn = "prep"
var turnQueue := []
var unitPrepPositions := {}

var playerHP = 10
var curRound := Round.new()

func _ready():
	randomize()
	# assign Units to grid
	for unit in $Units.get_children():
		grid.addUnit(unit)
	prepTurn()

func prepTurn():
	turn = "prep"
	phaseAnimPlayer.play("Prep")
	yield(phaseAnimPlayer, "animation_finished")
	yield(get_tree().create_timer(0.5), "timeout")
	$UI/Bench.show()
	$UI/Shop.show()

func takePlayerTurn():
	turn = "player"
	phaseAnimPlayer.play("Combat")
	yield(phaseAnimPlayer, "animation_finished")
	yield(get_tree().create_timer(0.5), "timeout")
	$UI/Bench.hide()
	$UI/Shop.hide()
	
	#record unit positions here, return them at the end
	setUnitPrepPositions()
	doTurnQueue()

func getAllUnits():
	var units = get_tree().get_nodes_in_group("Player")
	units.append_array(get_tree().get_nodes_in_group("Enemy"))
	return units

func setUnitPrepPositions():
	var units = getAllUnits()
	unitPrepPositions.clear()
	for unit in units:
		unitPrepPositions[unit] = unit.position

func doTurnQueue():
	turnQueue = getAllUnits()
	turnQueue.shuffle()
	
	for i in range(0, turnQueue.size()):
		var unit = turnQueue[i]
		# units that go last bring it back to "prepTurn"
		if unit == turnQueue.back():
			unit.connect("turn_done", self, "nextUnitTurn", [turnQueue.front()], CONNECT_DEFERRED)
		else:
			unit.connect("turn_done", self, "nextUnitTurn", [turnQueue[i + 1]], CONNECT_DEFERRED)
	nextUnitTurn(turnQueue.front())

func checkUnitGroupWiped(group):
	var unitGroup = get_tree().get_nodes_in_group(group)
	for unit in unitGroup:
		if !unit.queuedForDeath:
			return false
	return true

func nextUnitTurn(unit: Unit):
	#first, check if we hit a victory/defeat condition
	if checkUnitGroupWiped("Enemy"):
		finishPlayerTurn(true)
		return
	elif checkUnitGroupWiped("Player"):
		finishPlayerTurn(false)
		return
	
	unit.takeTurn()

func finishPlayerTurn(victory):
	# count points of damage 
	if !victory:
		var enemyDamage = 0
		for unit in get_tree().get_nodes_in_group("Enemy"):
			enemyDamage += 1
		
		playerHP -= enemyDamage
		$UI/PlayerStats/PlayerHP.text = str("Player Health ", max(0, playerHP))
		if playerHP <= 0:
			print("YOU LOSE.... LOSER!!!")
	# clean up remaining units
	for i in range(0, turnQueue.size()):
		var unit = turnQueue[i]
		#return to original cell position
		unit.position = unitPrepPositions[unit]
		unit.reset()
		unit.disconnect("turn_done", self, "nextUnitTurn")
	# add unit to player bench
	var newUnit = bench.createShopUnit()
	newUnit.connect("dropped", self, "dropShopUnit")
	bench.addShopUnit(newUnit)
	
	# add enemy unit to field
	var enemyWorldPos = grid.tileMap.map_to_world(curRound.nextEnemyPosition())
	spawnUnit(enemyWorldPos, "Enemy")
	
	# increment round
	curRound.increment()
	$UI/PlayerStats/RoundNum.text = str("Round ", curRound.num)
	# go to prep
	prepTurn()

func _unhandled_input(event):
#	if event is InputEventMouseButton:
#		if event.pressed and event.button_index == BUTTON_LEFT:
#			if grid.validPathv(testUnit.position, event.position):
#				for unit in get_tree().get_nodes_in_group("Player"):
#					unit.setDestination(event.position)
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			if turn == "prep":
				takePlayerTurn()
		if !event.pressed and event.scancode == KEY_ENTER:
			print("enterrrrrrr")
			$"Units/Unit/2DShaker".hShake()

func dropShopUnit(draggable):
	#if we drop a unit on an empty space, spawn a unit
	var mousePos = get_global_mouse_position()
	#check if its a valid space
	var cellId = grid.getCellId(mousePos)
	if grid.getTileName(cellId) != "Walkable":
		draggable.rect_position = draggable.beforeDragPos
		return
	
	draggable.hide()
	spawnUnit(mousePos, "Player")

func spawnUnit(pos: Vector2, affiliation: String):
	#create unit and add to grid
	var newUnit = unitTscn.instance()
	newUnit.affiliation = affiliation
	newUnit.position = grid.getSnappedPosv(pos) + grid.tileMap.cell_size/2
	grid.addUnit(newUnit)
	$Units.add_child(newUnit)

func _on_AtttackBtn_pressed():
	print("bla;fbaiwueskf!")
#	if castles.empty():
#		return
#	if grid.validPath(testUnit.position, castles.front()):
#		print("Castle is next dest!")
#		testUnit.setDestination(castles.front())

class Round:
	var num := 1
	var maxEnemies := 2
	var enemyPositions := [Vector2(16, 8), Vector2(13, 8)]

	func _init():
		pass

	func increment():
		num += 1
	
	func nextEnemyPosition():
		if num < maxEnemies:
			return enemyPositions[num]
