extends Node2D

# branched scenes
var unitTscn = preload("res://Unit/Unit.tscn")

onready var grid = $Grid
onready var phaseAnimPlayer = $UI/Phase/AnimationPlayer
onready var prepUI = $UI/PrepMenu

var turn = "prep"
var turnQueue = []

func _ready():
	randomize()
	# assign Units to grid
	for unit in $Units.get_children():
		grid.addUnit(unit)
	prepTurn()
	#for testing shop
	$UI/Bench/Panel/UnitSlot1/ShopUnit.connect("dropped", self, "dropShopUnit")

func prepTurn():
	turn = "prep"
	phaseAnimPlayer.stop()
	phaseAnimPlayer.play("Prep")
	#prepUI.show()
	$UI/Bench.show()
	$UI/Shop.show()

func takePlayerTurn():
	turn = "player"
	phaseAnimPlayer.stop()
	phaseAnimPlayer.play("Combat")
	#prepUI.hide()
	$UI/Bench.hide()
	$UI/Shop.hide()
	turnQueue = get_tree().get_nodes_in_group("Player")
	var enemies = get_tree().get_nodes_in_group("Enemy")
	turnQueue.append_array(enemies)
	randomize()
	turnQueue.shuffle()
	
	for i in range(0, turnQueue.size()):
		var unit = turnQueue[i]
		# units that go last bring it back to "prepTurn"
		if unit == turnQueue.back():
			unit.connect("turn_done", self, "prepTurn", [], CONNECT_ONESHOT)
		else:
			unit.connect("turn_done", turnQueue[i + 1], "takeTurn", [], CONNECT_ONESHOT)
	turnQueue.front().takeTurn()

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
#	if grid.getTileName(cellId) != "walkable":
#		return
	
	draggable.hide()
	#create unit and add to grid
	var newUnit = unitTscn.instance()
	newUnit.position = grid.getSnappedPosv(mousePos) + grid.tileMap.cell_size/2
	grid.addUnit(newUnit)
	$Units.add_child(newUnit)

func _on_AtttackBtn_pressed():
	print("bla;fbaiwueskf!")
#	if castles.empty():
#		return
#	if grid.validPath(testUnit.position, castles.front()):
#		print("Castle is next dest!")
#		testUnit.setDestination(castles.front())
