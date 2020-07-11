extends Sprite

onready var path2D = get_tree().current_scene.get_node("Grid/Path")
var grid: Grid

var cellPos = Vector2(0, 0)

var moving = false
var path = []
var moveSpeed = 64

func _process(delta):
	if moving:
		if path.empty():
			moveComplete()
			return
		position = position.move_toward(path[0], delta * moveSpeed)
		if position.distance_to(path[0]) < 0.05:
			path.pop_front()

func gotoCellv(cellPosv: Vector2):
	#we are in world space, we need to change that
	path = grid.getPathv(position, cellPosv)
	path2D.points = path
	moving = true

func moveComplete():
	moving = false
	path2D.points = []
	cellPos = grid.getGridPos(position)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			print("clicky click")
			if !moving:
				gotoCellv(event.position)
