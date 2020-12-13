extends Sprite
class_name Unit

onready var path2D = get_tree().current_scene.get_node("Grid/Path")
onready var destMark = get_tree().current_scene.get_node("Grid/DestMark")
var grid: Grid

var cellPos = Vector2(0, 0)

var moving = false
var path = []
var moveSpeed = 64

var destination = null
var targets = []

export(String) var affiliation = "Player"

onready var currHp = hp
export(int) var hp = 14
export(int) var atk = 5
export(int) var def = 5
export(int) var skl = 5
export(int) var lck = 5
export(int) var spd = 5

export(int) var mov = 5

signal attack_done
signal damage_taken_done
signal turn_done

func _ready():
	destMark.hide()
	# set group for affiliation
	add_to_group(affiliation)

func _process(delta):
	if moving:
		if path.empty():
			moveComplete()
			return
		position = position.move_toward(path[0], delta * moveSpeed)
		if position.distance_to(path[0]) < 0.05:
			path.pop_front()

## DEPRECATED ##
#func gotoCellv(cellPosv: Vector2):
#	#we are in world space, we need to change that
#	path = grid.getPathv(position, cellPosv)
#	path2D.points = path
#	moving = true

func setDestination(cellPosv: Vector2):
	destination = grid.getGridPos(cellPosv)
	path = grid.getPath(cellPos, destination)
	destMark.position = destination * grid.tileMap.cell_size
	destMark.show()

func moveComplete():
	moving = false
	destination = null
	path2D.points = []
	cellPos = grid.getGridPos(position)
	
	#initiate combat??
	if checkAdjacentToTarget():
		CombatProcessor.connect("combat_done", self, "emit_signal", ["turn_done"], CONNECT_ONESHOT)
		CombatProcessor.battle(self, targets.front())
	else:
		emit_signal("turn_done")

func findTarget():
	var potentialTargets
	if affiliation == "Player":
		potentialTargets = get_tree().get_nodes_in_group("Enemy")
	if affiliation == "Enemy":
		potentialTargets = get_tree().get_nodes_in_group("Player")
	
	if potentialTargets.empty():
		return
	
	var low = INF
	var lowTarget = null
	for target in potentialTargets:
		# TODO: Probably change this later. We weigh target
		#  importance based on distance from unit to potential targets
		var dist = cellPos.distance_squared_to(target.cellPos)
		if low > dist:
			low = dist
			lowTarget = target
	
	targets.append(lowTarget)

func updateDestination():
	if targets.empty():
		destination = null
		return
	destination = grid.getClosestToCellPos(cellPos, targets.front().cellPos)

func checkAdjacentToTarget():
	if cellPos.x == targets.front().cellPos.x and \
		abs(cellPos.y - targets.front().cellPos.y) == 1:
		return true
	if cellPos.y == targets.front().cellPos.y and \
		abs(cellPos.x - targets.front().cellPos.x) == 1:
		return true
	return false

func takeTurn():
	if targets.empty():
		findTarget()
	
	updateDestination()
	if destination == null:
		return
	
	var longpath = grid.getPath(cellPos, destination)
	for i in range(0, mov + 1):
		var dest_node = longpath.pop_front()
		if dest_node != null:
			path.append(dest_node)
		else:
			break
	path2D.points = path
	moving = true

func attack(other: Unit):
	# TODO change this for atk vs mag depending on weapon
	var damage = atk + 8 # weapon damage magic num
	var hit = (skl * 2) + (lck/2) + 70 # weapon hit magic num
	var crit = (skl/2) + 0 # weapon crit magic num
	print("DAMAGE: ", damage, ", HIT%: ", hit, ", CRIT%: ", crit)
	
	#roll for hit and crit
	var didHit = false
	var didCrit = false
	var dealtDamage = -1
	
	print(name, " attacks and...")
	if ((randi() % 101) + 1 < hit): #minus enemy avoid
		print("hits!")
		didHit = true
		dealtDamage = damage #minus enemy def/res
		if ((randi() % 101) + 1 < crit): #minus enemy luck
			print("and crits!")
			didCrit = true
			dealtDamage *= 2
	
	#animation
	#var tween = Tween.new()
	#tween
	var timer = get_tree().create_timer(.5)
	timer.connect("timeout", other, "takeDamage", [dealtDamage])
	other.connect("damage_taken_done", self, "emit_signal", ["attack_done"], CONNECT_ONESHOT)
	
func takeDamage(dmg):
	$HealthUI.show()
	if dmg == -1:
		print("Miss!")
		#miss animation
	else:
		print(name, " takes ", dmg, "damage!")
		
		currHp -= dmg
		print(name, " health: ", currHp, "/", hp)
		updateHealthUI()
		if currHp <= 0:
			print("oh no... go on... without meeeeee. (dead)")
	var timer = get_tree().create_timer(.5)
	timer.connect("timeout", self, "emit_signal", ["damage_taken_done"], CONNECT_ONESHOT)

func updateHealthUI():
	var healthbar = $HealthUI/FG
	healthbar.margin_right = -max(0, float(hp - currHp))/float(hp) * healthbar.rect_size.x


func _on_mouse_entered():
	get_node("/root/Game/UI/StatPreview").setStats(self)


func _on_mouse_exited():
	get_node("/root/Game/UI/StatPreview").hide()
