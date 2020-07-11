extends Node2D

onready var grid = $Grid
onready var testUnit = $Grid/Units/Unit

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if grid.validPathv(testUnit.position, event.position):
				testUnit.setDestination(event.position)
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			if !testUnit.moving:
				$UI/TakeTurn/AnimationPlayer.stop()
				$UI/TakeTurn/AnimationPlayer.play("Show")
				testUnit.takeTurn()
