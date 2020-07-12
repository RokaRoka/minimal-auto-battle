extends Sprite

onready var path2D = get_tree().current_scene.get_node("Grid/Path")
onready var destMark = get_tree().current_scene.get_node("Grid/DestMark")
var grid: Grid

var cellPos = Vector2(0, 0)

var moving = false
var path = []
var moveSpeed = 64

var destinations = [null]

export var moveRange = 5

signal turn_done

func _ready():
	destMark.hide()

func _process(delta):
	if moving:
		if path.empty():
			moveComplete()
			return
		position = position.move_toward(path[0], delta * moveSpeed)
		if position.distance_to(path[0]) < 0.05:
			path.pop_front()

## DEPRECATED ##
func gotoCellv(cellPosv: Vector2):
	#we are in world space, we need to change that
	path = grid.getPathv(position, cellPosv)
	path2D.points = path
	moving = true

func setDestination(cellPosv: Vector2):
	destinations[0] = grid.getPathv(position, cellPosv)
	destMark.position = destinations[0].back()
	destMark.show()

func moveComplete():
	moving = false
	path2D.points = []
	cellPos = grid.getGridPos(position)
	emit_signal("turn_done")

func takeTurn():
	if destinations.empty() or destinations[0] == null:
		return
	for i in range(0, moveRange + 1):
		var dest_node = destinations.front().pop_front()
		if dest_node != null:
			path.append(dest_node)
		else:
			break
	path2D.points = path
	moving = true
