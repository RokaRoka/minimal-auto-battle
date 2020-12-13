class_name Grid
extends Node2D

var astar: AStar2D
onready var tileMap = $TileMap
#Grid information is determined by tilemap. Navigation is based on tilemap.
## TILEMAP RULES ALL ##

# The Unit Grid is offset and at a different size than the rest of the tilemap
# This is important for astar
# i.e. [3, 5] on the tilemap is [0, 0] for the unit grid
var gridRect: Rect2
var unitGrid = []

func _ready():
	astar = AStar2D.new()
	
	gridRect = tileMap.get_used_rect()
	print("Grid rect: ", gridRect)
	
	var cellAmount = gridRect.size
	print("Cell size: ", cellAmount)
	unitGrid.resize(cellAmount.x * cellAmount.y)
	
	# set astar points
	print("Setting Astar")
	astar.reserve_space(cellAmount.x * cellAmount.y)
	for i in range(0, cellAmount.y):
		for j in range(0, cellAmount.x):
			#check if there is a cell here, otherwize we skip
			var cell = tileMap.get_cell(j + gridRect.position.x, i + gridRect.position.y)
			if cell == tileMap.INVALID_CELL:
				continue
			var tiletype = getTileName(cell)
			if !tiletype == "Walkable":
				continue
			
			var id = j + (i * cellAmount.x)
			var cellPos = (gridRect.position + Vector2(j + 0.5, i + 0.5)) * tileMap.cell_size
			astar.add_point(id, cellPos)
			#print("Id: ", id, " at pos: ", cellPos)
			
			# connecting time... fuck
			# check behind
			if astar.has_point(id - 1) and !astar.are_points_connected(id - 1, id):
				#print("connected! ", id - 1, " and ", id)
				astar.connect_points(id - 1, id)
			# check above
			if astar.has_point(id - cellAmount.x) and !astar.are_points_connected(id - cellAmount.x, id):
				#print("connected! ", id - cellAmount.x, " and ", id)
				astar.connect_points(id - cellAmount.x, id)
	
	# astar test
#	var pathPlayer = astar.get_id_path(0, 63)
#	print("path from top left to botton right! Points: ", pathPlayer)

func getGridOriginv():
	return gridRect.position * tileMap.cell_size

func addUnit(var unit):
	unit.grid = self
	unit.cellPos = tileMap.world_to_map(unit.position) - gridRect.position
	print("Adding Unit. Cell Pos : ", unit.cellPos)
	unitGrid[unit.cellPos.x + (gridRect.size.x * unit.cellPos.y)]

func getUnit(var cellPos):
	return unitGrid[cellPos.x + (gridRect.size.x * cellPos.y)]

#takes in world based positions [32, 64] or [78.5, 54.2]
func getPathv(cellPosv1, cellPosv2):
	# MORE LIKe ASSTAR AMIRITE LOL
	var cellPos1 = tileMap.world_to_map(cellPosv1)
	var cellPos2 = tileMap.world_to_map(cellPosv2)
	
	if !validPathv(cellPosv1, cellPosv2):
		return []
	
	#cellPos1 -= gridRect.position
	#cellPos2 -= gridRect.position
	var astarId1 = cellPos1.x + (cellPos1.y * gridRect.size.x)
	var astarId2 = cellPos2.x + (cellPos2.y * gridRect.size.x)
	var path = Array(astar.get_point_path(astarId1, astarId2))
	path = path.slice(1, path.size())
	return path

#takes in cell based positions [0, 1] or [4, 3] etc
#returns the next node to move to from cellpos1, up until cellpos2
func getPath(cellPos1, cellPos2):
	if !validPath(cellPos1, cellPos2):
		return []
	
	#cellPos1 -= gridRect.position
	#cellPos2 -= gridRect.position
	var astarId1 = cellPos1.x + (cellPos1.y * gridRect.size.x)
	var astarId2 = cellPos2.x + (cellPos2.y * gridRect.size.x)
	var path = Array(astar.get_point_path(astarId1, astarId2))
	path = path.slice(1, path.size())
	return path

func validPathv(cellPosv1, cellPosv2):
	var cellPos1 = tileMap.world_to_map(cellPosv1) - gridRect.position
	var cellPos2 = tileMap.world_to_map(cellPosv2) - gridRect.position
	return validPath(cellPos1, cellPos2)

func validPath(cellPos1, cellPos2):
	# TODO: fine consistent naming for astar/unit grid and tilemap
	# This is some bullshit basically
	var cell1 = cellPos1 + gridRect.position
	var cell2 = cellPos2 + gridRect.position
	if !gridRect.has_point(cell1) or !gridRect.has_point(cell2):
		return false
	
	var cell = tileMap.get_cell(cell1.x, cell1.y)
	if cell == tileMap.INVALID_CELL:
		return false
	
	cell = tileMap.get_cell(cell2.x, cell2.y)
	if cell == tileMap.INVALID_CELL:
		return false
	
	#destination has to be walkable!
	var tiletype = getTileName(cell)
	if !tiletype == "Walkable":
		return false
	return true

func getGridPos(posv):
	return tileMap.world_to_map(posv) - gridRect.position

func getSnappedPosv(pos):
	return tileMap.world_to_map(pos) * tileMap.cell_size

func getCellId(pos):
	var cellPos = tileMap.world_to_map(pos)# - gridRect.position
	return tileMap.get_cellv(cellPos)

func getTileName(id):
	return tileMap.tile_set.tile_get_name(id)

# for when we are attacking enemies
func getClosestToCellPos(curPos, targetPos, limitMovement = -1):
	#var diff = targetPos.distance_squared_to(curPos)
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	
	# remove literally unreachable locations
	for i in range(0, 4):
		var pos = targetPos + dirs[i]
		var cell = tileMap.get_cell(pos.x + gridRect.position.x, pos.y + gridRect.position.y)
		var tiletype = getTileName(cell)
		if !tiletype == "Walkable" or getUnit(pos) != null:
			dirs.remove(i)
			continue
	
	if limitMovement > -1:
		for i in range(0, dirs.size()):
			var pos = targetPos + dirs[i]
			var dist = curPos - pos
			if limitMovement >= (abs(dist.x) + abs(dist.y)):
				print("closest: ", targetPos + dirs[i])
				return targetPos + dirs[i]
	
	print("closest: ", targetPos + dirs.front())
	return targetPos + dirs.front()
	
	# AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH
#	if sign(diff.x) > 0:
#		if sign(diff.y) > 0:
#			if abs(diff.x) > abs(diff.y):
#				#East
#				final = diff + Vector2.RIGHT
#			else:
#				#South
#				final = diff + Vector2.DOWN
#		else:
#			if abs(diff.x) > abs(diff.y):
#				#East
#				final = diff + Vector2.RIGHT
#			else:
#				#North
#				final = diff + Vector2.UP
#	elif sign(diff.x) < 0:
#		if sign(diff.y) > 0:
#			if abs(diff.x) > abs(diff.y):
#				#West
#				final = diff + Vector2.LEFT
#			else:
#				#South
#				final = diff + Vector2.DOWN
#		else:
#			if abs(diff.x) > abs(diff.y):
#				#West
#				final = diff + Vector2.LEFT
#			else:
#				#North
#				final = diff + Vector2.UP
#	else:
#		if sign(diff.y) > 0:
#			#south
#			final = diff + Vector2.DOWN
#		else:
#			#north
#			final = diff + Vector2.UP

func getTilesOfType(name):
	# first, get the id of name
	var id = tileMap.tile_set.find_tile_by_name(name)
	if id == null:
		return null
	return tileMap.get_used_cells_by_id(id)
