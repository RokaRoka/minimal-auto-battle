extends Sprite

onready var path2D = $Path
var grid: Grid

var cellPos = Vector2(0, 0)

var moving = false
var path = []
var moveSpeed = 100

func _process(delta):
	if moving:
		if path.empty():
			moving = false
			return

func gotoCellv(cellPosv: Vector2):
	#we are in world space, we need to change that
	path = grid.getPathv(position, cellPosv)
	path2D.points = path
	#moving = true

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			print("clicky click")
			gotoCellv(event.position)
