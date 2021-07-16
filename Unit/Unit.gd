extends Sprite
class_name Unit

onready var path2D = get_tree().current_scene.get_node("Grid/Path")
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

export(int) var mov = 6

signal attack_done(unit)
signal damage_taken(unit)
signal damage_taken_done(unit)
signal turn_done(unit)

func _ready():
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

func moveComplete():
	moving = false
	destination = null
	path2D.points = []
	grid.moveUnit(self, grid.getGridPos(position))
	
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
	destination = grid.getClosestToCellPos(cellPos, targets.front().cellPos, mov)

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
	
	if !checkAdjacentToTarget():
		updateDestination()
	else:
		CombatProcessor.connect("combat_done", self, "emit_signal", ["turn_done"], CONNECT_ONESHOT)
		CombatProcessor.battle(self, targets.front())
		return
	
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

func getHit():
	return (skl * 2) + (lck/2) + 75 # weapon hit magic num

func getAvo():
	return lck - spd

func getCrit():
	return (skl/2) + 2 # weapon crit magic num

func attack(other: Unit):
	# TODO change this for atk vs mag depending on weapon
	var damage = atk + 7 # weapon damage magic num
	var hit = getHit()
	var crit = getCrit()
	
	print(name, " attacks!")
	print("DAMAGE: ", damage, ", HIT%: ", hit, ", CRIT%: ", crit)
	
	#roll for hit and crit
	var didHit = false
	var dealtDamage = -1
	if (randi() % 101) + 1 < hit - other.getAvo(): #minus enemy avoid
		print("They hits!")
		didHit = true
		dealtDamage = max(0, damage - other.def)
		if ((randi() % 101) + 1 < crit): 
			print("and they crit!!!")
			dealtDamage *= 2
			#crit animation
		#attack animation
	
	#var tween = Tween.new()
	#tween
	var timer = get_tree().create_timer(.75)
	timer.connect("timeout", other, "takeDamage", [dealtDamage])
	other.connect("damage_taken_done", self, "emit_signal", ["attack_done"], CONNECT_ONESHOT)
	
func takeDamage(dmg):
	if dmg == -1:
		print("Miss!")
		#miss animation
	elif dmg == 0:
		print("No Dmg!")
	else:
		print(name, " takes ", dmg, " damage!")
		currHp -= dmg
		print(name, " health: ", currHp, "/", hp)
		emit_signal("damage_taken", self)
		#updateHealthUI()
		if currHp <= 0:
			print("oh no... go on... without meeeeee. (dead)")
	#damage animation!
	
	$"2DShaker".connect("shakeDone", self, "emit_signal", ["damage_taken_done"], CONNECT_ONESHOT)
	$"2DShaker".hShake()
	#var timer = get_tree().create_timer(1.0)
	#timer.connect("timeout", self, "emit_signal", ["damage_taken_done"], CONNECT_ONESHOT)
#	timer.connect("timeout", get_node("/root/Game/UI/Combat"), "hide", [], CONNECT_ONESHOT)

func updateHealthUI():
	var healthbar = $HealthUI/FG
	#print("zero to one: ", float(max(0, currHp))/float(hp))
	healthbar.rect_scale.x = float(max(0, currHp))/float(hp)
	


func _on_mouse_entered():
	get_node("/root/Game/UI/StatPreview").setStats(self)


func _on_mouse_exited():
	get_node("/root/Game/UI/StatPreview").hide()
