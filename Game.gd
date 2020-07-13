extends Node2D

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


func _on_AtttackBtn_pressed():
	print("bla;fbaiwueskf!")
	if castles.empty():
		return
	if grid.validPath(testUnit.position, castles.front()):
		print("Castle is next dest!")
		testUnit.setDestination(castles.front())
