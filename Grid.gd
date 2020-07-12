class_name Grid
extends Node2D

var astar: AStar2D
onready var tileMap = $TileMap
#Grid information is determined by tilemap. Navigation is based on tilemap.
## TILEMAP RULES ALL ##

#grids (or uh, just one grid)
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
			print("Id: ", id, " at pos: ", cellPos)
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
	# assign Units to grid
	for unit in $Units.get_children():
		addUnit(unit)

func getGridOriginv():
	return gridRect.position * tileMap.cell_size

func addUnit(var unit):
	unit.grid = self
	unit.cellPos = tileMap.world_to_map(unit.position) - gridRect.position
	unitGrid[unit.cellPos.x + (10 * unit.cellPos.y)]

func getUnit(var cellPos):
	return unitGrid[cellPos.x + (10 * cellPos.y)]

func getPathv(cellPosv1, cellPosv2):
	# MORE LIKe ASSTAR AMIRITE LOL
	var cellPos1 = tileMap.world_to_map(cellPosv1)
	var cellPos2 = tileMap.world_to_map(cellPosv2)
	
	if !validPathv(cellPosv1, cellPosv2):
		return []
	
	cellPos1 -= gridRect.position
	cellPos2 -= gridRect.position
	var astarId1 = cellPos1.x + (cellPos1.y * gridRect.size.x)
	var astarId2 = cellPos2.x + (cellPos2.y * gridRect.size.x)
	return Array(astar.get_point_path(astarId1, astarId2))

func getPath(cellPos1, cellPos2):
	if !validPath(cellPos1, cellPos2):
		return []
	
	cellPos1 -= gridRect.position
	cellPos2 -= gridRect.position
	var astarId1 = cellPos1.x + (cellPos1.y * gridRect.size.x)
	var astarId2 = cellPos2.x + (cellPos2.y * gridRect.size.x)
	return Array(astar.get_point_path(astarId1, astarId2))

func getGridPos(posv):
	return tileMap.world_to_map(posv) - gridRect.position

func getTileName(id):
	return tileMap.tile_set.tile_get_name(id)

func validPathv(cellPosv1, cellPosv2):
	var cellPos1 = tileMap.world_to_map(cellPosv1)
	var cellPos2 = tileMap.world_to_map(cellPosv2)
	return validPath(cellPos1, cellPos2)

func validPath(cellPos1, cellPos2):	
	#return blank array for out of bound paths
	if !gridRect.has_point(cellPos1) or !gridRect.has_point(cellPos2):
		return false
	
	var cell = tileMap.get_cell(cellPos1.x, cellPos1.y)
	if cell == tileMap.INVALID_CELL:
		return false
	
	cell = tileMap.get_cell(cellPos2.x, cellPos2.y)
	if cell == tileMap.INVALID_CELL:
		return false
	
	#destination has to be walkable!
	var tiletype = getTileName(cell)
	if !tiletype == "Walkable":
		return false
	return true

func getTilesOfType(name):
	# first, get the id of name
	var id = tileMap.tile_set.find_tile_by_name(name)
	if id == null:
		return null
	return tileMap.get_used_cells_by_id(id)
