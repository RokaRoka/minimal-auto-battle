extends Sprite
class_name Unit

onready var path2D = get_tree().current_scene.get_node("Grid/Path")
onready var destMark = get_tree().current_scene.get_node("Grid/DestMark")
var grid: Grid

var cellPos = Vector2(0, 0)

var moving = false
var path = []
var moveSpeed = 64

var destinations = [null]

export var hp = 14
export var atk = 5
export var def = 5
export var skl = 5
export var lck = 5
export var spd = 5

export var moveRange = 5

signal attack_done
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

func attack(other: Unit):
	var damage = atk + 8 #plus weapons when we get there lol
	var hit = (skl * 2) + (lck/2) + 70 
	var crit = (skl/2) + 5
	#roll for hit
	
	#roll for crit
	
	#animation
