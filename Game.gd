extends Node2D

# branched scenes
var unitTscn = preload("res://Unit.tscn")

onready var grid = $Grid
onready var testUnit = $Grid/Units/Unit
onready var turnUIAnim = $UI/TakeTurn/AnimationPlayer
onready var prepUI = $UI/PrepMenu

var turn = "prep"
var turnQueue = []

var currentCastle
var castles = []

func _ready():
	castles = grid.getTilesOfType("Castle")
	prepTurn()
	$UI/Bench/Panel/UnitSlot1/ShopUnit.connect("dropped", self, "dropShopUnit")

func prepTurn():
	turn = "prep"
	turnUIAnim.stop()
	turnUIAnim.play("Prep")
	#prepUI.show()

func takePlayerTurn():
	turn = "player"
	turnUIAnim.stop()
	turnUIAnim.play("PlayerTurn")
	#prepUI.hide()
#	turnQueue = get_tree().get_nodes_in_group("player")
	testUnit.connect("turn_done", self, "prepTurn", [], CONNECT_ONESHOT)
	testUnit.takeTurn()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if grid.validPathv(testUnit.position, event.position):
				testUnit.setDestination(event.position)
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			if turn == "prep":
				takePlayerTurn()

func dropShopUnit(draggable):
	#if we drop a unit on an empty space, spawn a unit
	var mousePos = get_global_mouse_position()
	#check if its a valid space
	var cellId = grid.getCellId(mousePos)
	draggable.hide()
	#create unit and add to grid
	var newUnit = unitTscn.instance()
	newUnit.position = grid.getSnappedPos(mousePos) + grid.tileMap.cell_size/2
	grid.addUnit(newUnit)
	$Grid/Units.add_child(newUnit)

func _on_AtttackBtn_pressed():
	print("bla;fbaiwueskf!")
	if castles.empty():
		return
	if grid.validPath(testUnit.position, castles.front()):
		print("Castle is next dest!")
		testUnit.setDestination(castles.front())
