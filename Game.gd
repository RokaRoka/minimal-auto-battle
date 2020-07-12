extends Node2D

onready var grid = $Grid
onready var testUnit = $Grid/Units/Unit
onready var turnUIAnim = $UI/TakeTurn/AnimationPlayer


var turn = "prep"
var turnQueue = []

func _ready():
	prepTurn()

func prepTurn():
	turn = "prep"
	turnUIAnim.stop()
	turnUIAnim.play("Prep")

func takePlayerTurn():
	turn = "player"
	turnUIAnim.stop()
	turnUIAnim.play("PlayerTurn")
	turnQueue = get_tree().get_nodes_in_group("player")
	turnQueue[0].takeTurn()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if grid.validPathv(testUnit.position, event.position):
				testUnit.setDestination(event.position)
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			if turn == "prep":
				takePlayerTurn()
