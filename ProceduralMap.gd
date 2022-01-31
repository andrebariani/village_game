extends Node2D

onready var camera = $Camera2D
onready var procUi = $Camera2D/ProcDebug/TabContainer
onready var posLabel = $Camera2D/pos
onready var grasscapOpBt = $Camera2D/ProcDebug/TabContainer/grass/Cap/grasscap
onready var mtcapOpBt = $Camera2D/ProcDebug/TabContainer/mt/Cap/mtcap
onready var islandcapOpBt = $Camera2D/ProcDebug/TabContainer/island/Cap/islandcap
export var SCROLL_SPEED = 2
var zoom = true
var scroll_multi = 1

var noise = OpenSimplexNoise.new()

onready var tilemapBuildings = $Buildings
onready var tilemapRoads = $Roads

onready var tilemapMountains = $Mountains
var mountains_map_size = Vector2(50, 28)

onready var tilemapGround = $Paths
onready var tilemapIslands = $Paths2
onready var tilemapTree = $Trees
var ground_map_size = Vector2(400, 224)

var layers = {
	"grass": {
		map_size = Vector2(400, 224),
		noise = OpenSimplexNoise.new(),
		octaves = 5.0,
		period = 64,
		cap = 0,
		cap_op = true,
		use_same_noise = true,
	},
	"mt": {
		map_size = Vector2(50, 28),
		noise = OpenSimplexNoise.new(),
		octaves = 3,
		period = 8,
		cap = 0.35,
		cap_op = true,
		use_same_noise = true
	},
	"island": {
		map_size = Vector2(400, 224),
		noise = OpenSimplexNoise.new(),
		octaves = 0,
		period = 12,
		cap = 0.7,
		cap_op = true,
		use_same_noise = true
	},
	"tree": {
		map_size = Vector2(400, 224),
		noise = OpenSimplexNoise.new(),
		octaves = 2,
		period = 24,
		cap = 0.4,
		cap_op = true,
		use_same_noise = true
	},
}


func _ready():
	_set_sliders()
	generate_map()
	toggle_zoom()


func generate_map():
	generate_mountains()
	generate_grass()
	generate_islands()
	generate_rivers()
	generate_trees()


func generate_mountains():
	tilemapMountains.clear()
	var layer = layers.mt
	
	var n = noise if layer.use_same_noise else layer.noise
	
	n.octaves = layer.octaves
	n.period = layer.period
	
	print_debug(n.octaves, " / ", n.period)
	
	for x in layer.map_size.x:
		for y in layer.map_size.y:
			var n_cell = n.get_noise_2d(x, y)
			#tilemapGround.set_cellv(Vector2(x,y), 2)
			if layer.cap_op:
				if n_cell > layer.cap:
					tilemapMountains.set_cellv(Vector2(x,y), 0)
			else:
				if n_cell < layer.cap:
					tilemapMountains.set_cellv(Vector2(x,y), 0)
			#tilemapGround.update_bitmask_area(Vector2(x,y))


func generate_grass():
	tilemapGround.clear()
	var layer = layers.grass
	
	var n = noise if layer.use_same_noise else layer.noise
	
	n.octaves = layer.octaves
	n.period = layer.period
	
	print_debug(n.octaves, " / ", n.period)
	
	for x in layer.map_size.x:
		for y in layer.map_size.y:
			var n_cell = n.get_noise_2d(x, y)
			tilemapGround.set_cellv(Vector2(x,y), 7)
			if layer.cap_op:
				if n_cell > layer.cap:
					tilemapGround.set_cellv(Vector2(x,y), 8)
			else:
				if n_cell < layer.cap:
					tilemapGround.set_cellv(Vector2(x,y), 8)
			tilemapGround.update_bitmask_area(Vector2(x,y))


func generate_islands():
	# tilemapIslands.clear()
	var layer = layers.island
	
	var n = noise if layer.use_same_noise else layer.noise
	
	n.octaves = layer.octaves
	n.period = layer.period
	
	print_debug(n.octaves, " / ", n.period)
	
	for x in layer.map_size.x:
		for y in layer.map_size.y:
			var n_cell = n.get_noise_2d(x, y)
			if layer.cap_op:
				if n_cell > layer.cap:
					tilemapGround.set_cellv(Vector2(x,y), 8)
			else:
				if n_cell < layer.cap:
					tilemapGround.set_cellv(Vector2(x,y), 8)
			tilemapGround.update_bitmask_area(Vector2(x,y))


func generate_rivers():
	noise.octaves = layers.grass.octaves
	noise.period = layers.grass.period
	
	for x in layers.mt.map_size.x:
		for y in layers.mt.map_size.y:
			if tilemapMountains.get_cellv(Vector2(x, y)) == 0:
				if tilemapMountains.get_cellv(Vector2(x, y + 1)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapGround.world_to_map(mtPos) + Vector2(4, 7)
						tilemapGround.set_cellv(spring, 7)
						spring += Vector2.DOWN
						walker_river(spring)
				elif tilemapMountains.get_cellv(Vector2(x, y - 1)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapGround.world_to_map(mtPos) + Vector2(4, 0)
						tilemapGround.set_cellv(spring, 7)
						spring += Vector2.UP
						walker_river(spring)
				elif tilemapMountains.get_cellv(Vector2(x + 1, y)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapGround.world_to_map(mtPos) + Vector2(7, 4)
						tilemapGround.set_cellv(spring, 7)
						spring += Vector2.RIGHT
						walker_river(spring)
				elif tilemapMountains.get_cellv(Vector2(x - 1, y)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapGround.world_to_map(mtPos) + Vector2(0, 4)
						tilemapGround.set_cellv(spring, 7)
						spring += Vector2.LEFT
						walker_river(spring)
						
	var river_cells = tilemapRoads.get_used_cells_by_id(3)
	for r in river_cells:
		tilemapGround.set_cellv(r, 7)
		tilemapGround.update_bitmask_area(r)


func generate_single_river(mt):
	print_debug("river at: ", str(mt))
	var x = mt.x
	var y = mt.y
	if tilemapMountains.get_cellv(Vector2(x, y)) == 0:
				if tilemapMountains.get_cellv(Vector2(x, y + 1)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapRoads.world_to_map(mtPos) + Vector2(4, 7)
						tilemapRoads.set_cellv(spring, 3)
						spring += Vector2.DOWN
						walker_river(spring)
				elif tilemapMountains.get_cellv(Vector2(x, y - 1)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapRoads.world_to_map(mtPos) + Vector2(4, 0)
						tilemapRoads.set_cellv(spring, 3)
						spring += Vector2.UP
						walker_river(spring)
				elif tilemapMountains.get_cellv(Vector2(x + 1, y)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapRoads.world_to_map(mtPos) + Vector2(7, 4)
						tilemapRoads.set_cellv(spring, 3)
						spring += Vector2.RIGHT
						walker_river(spring)
				elif tilemapMountains.get_cellv(Vector2(x - 1, y)) == -1:
					if (randi() % 100) < 25:
						var mtPos = tilemapMountains.to_global(tilemapMountains.map_to_world(Vector2(x, y)))
						var spring: Vector2 = tilemapRoads.world_to_map(mtPos) + Vector2(0, 4)
						tilemapRoads.set_cellv(spring, 3)
						spring += Vector2.LEFT
						walker_river(spring)


class cellSorter:
	static func sort_noise(a, b):
		if a[0] < b[0]:
			return true
		return false


func flood_lowlands(cell, max_height):
	pass


func walker_river(spring):
	var river = []
	while is_valid_river_cell(spring):
		river.push_back([noise.get_noise_2dv(spring), spring])
		tilemapRoads.set_cellv(spring, 3)
		tilemapGround.set_cellv(spring, -1)
		# yield(get_tree(), "idle_frame")
		var adj_cells = [
				[noise.get_noise_2dv(spring + Vector2.DOWN), spring + Vector2.DOWN],
				[noise.get_noise_2dv(spring + Vector2.LEFT), spring + Vector2.LEFT],
				[noise.get_noise_2dv(spring + Vector2.RIGHT), spring + Vector2.RIGHT],
				[noise.get_noise_2dv(spring + Vector2.UP), spring + Vector2.UP]
				]
		adj_cells.sort_custom(cellSorter, "sort_noise")
		while !adj_cells.empty():
			var adj = adj_cells.front()
			var world_pos = tilemapRoads.to_global(tilemapRoads.map_to_world(adj[1]))
			var mountain = tilemapMountains.world_to_map(world_pos)
			if tilemapRoads.get_cellv(adj[1]) != 3 and  \
				tilemapMountains.get_cellv(mountain) != 0:
				spring = adj[1]
				break
			adj_cells.pop_front()
	
	# print_debug(river)
	river.sort_custom(cellSorter, "sort_noise")
	return
	
	for i in range(1, river.size()):
		if river[i][0] == river[i - 1][0]:
			var max_height = river[i][0]
			flood_lowlands(river[i][1], max_height)
			flood_lowlands(river[i][1], max_height)

func is_valid_river_cell(spring):
	return tilemapGround.get_cellv(spring) != 7 and \
		tilemapRoads.get_cellv(spring) != 3 and \
		not is_outside_map_bounds(spring, ground_map_size)


func generate_trees():
	# tilemapIslands.clear()
	var layer = layers.tree
	
	var n = noise if layer.use_same_noise else layer.noise
	
	n.octaves = layer.octaves
	n.period = layer.period
	
	print_debug(n.octaves, " / ", n.period)
	
	for x in layer.map_size.x:
		for y in layer.map_size.y:
			if is_valid_tree_tile(Vector2(x, y)):
				continue
			var n_cell = n.get_noise_2d(x, y)
			if layer.cap_op:
				if n_cell > layer.cap:
					tilemapTree.set_cellv(Vector2(x,y), 1)
			else:
				if n_cell < layer.cap:
					tilemapTree.set_cellv(Vector2(x,y), 1)
			tilemapTree.update_bitmask_area(Vector2(x,y))


func is_valid_tree_tile(treePos: Vector2):
	var groundPos = convert_tilev(treePos, tilemapTree, tilemapGround)
	var mountainPos = convert_tilev(treePos, tilemapTree, tilemapMountains)
	return tilemapGround.get_cellv(groundPos) != 8 or \
		tilemapMountains.get_cellv(mountainPos) != -1

func convert_tilev(v: Vector2, from: TileMap, to: TileMap) -> Vector2:
	var globalPos = from.to_global(from.map_to_world(v))
	return to.world_to_map(globalPos)

func is_outside_map_bounds(point, map_size):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func _process(_delta):
	
	if Input.is_action_just_pressed("delete"):
		procUi.visible = !procUi.visible
	if Input.is_action_just_pressed("ui_select"):
		toggle_zoom()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		_on_Randomize_pressed()
	
	# Make River on selected mountain
	# if Input.is_action_just_pressed("ui_accept"):
		# var clicked_cell = tilemapMountains.world_to_map(get_global_mouse_position())
		# generate_single_river(clicked_cell)
	
	var scroll_dir = Vector2.ZERO
	scroll_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	scroll_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	camera.position += scroll_dir * SCROLL_SPEED * scroll_multi
	
	match (procUi.get_tab_title(procUi.current_tab)):
		"grass":
			var clicked_cell = tilemapGround.world_to_map(get_global_mouse_position())
			posLabel.set_text(str(clicked_cell))
			$Camera2D/seed.set_text(str(noise.get_noise_2dv(clicked_cell)))
		"mt":
			var clicked_cell = tilemapMountains.world_to_map(get_global_mouse_position())
			posLabel.set_text(str(clicked_cell))
			$Camera2D/seed.set_text(str(noise.get_noise_2dv(clicked_cell)))
		"island":
			var clicked_cell = tilemapIslands.world_to_map(get_global_mouse_position())
			posLabel.set_text(str(clicked_cell))
			$Camera2D/seed.set_text(str(noise.get_noise_2dv(clicked_cell)))
	


func toggle_zoom():
	zoom = !zoom
	if zoom:
		camera.zoom /= 8
		scroll_multi = 1
	else:
		camera.zoom *= 8
		scroll_multi = 12


func _on_GrassButton_pressed():
	_set_values("grass")
	generate_grass()


func _on_MtButton_pressed():
	_set_values("mt")
	generate_mountains()


func _set_values(key: String):
	var sliders = get_tree().get_nodes_in_group(key + "Sliders")
	for s in sliders:
		layers[key][s.name] = s.value


func _set_sliders():
	for l in layers.keys():
		print_debug(l)
		var sliders = get_tree().get_nodes_in_group(str(l) + "Sliders")
		for s in sliders:
			s.value = layers[l][s.name]


func _on_CheckBox_toggled(button_pressed):
	layers.grass.use_same_noise = button_pressed
	print_debug(layers.grass.use_same_noise)


func _on_grasscap_pressed():
	layers.grass.cap_op = !layers.grass.cap_op
	var op = ">" if layers.grass.cap_op else "<"
	grasscapOpBt.set_text(op)
	generate_grass()


func _on_Clear_pressed():
	tilemapRoads.clear()


func _on_mtButton_pressed():
	_set_values("mt")
	generate_mountains()


func _on_mtClear_pressed():
	tilemapMountains.clear()


func _on_mtcap_pressed():
	layers.mt.cap_op = !layers.mt.cap_op
	var op = ">" if layers.mt.cap_op else "<"
	mtcapOpBt.set_text(op)
	generate_mountains()


func _on_islandcap_pressed():
	layers.island.cap_op = !layers.island.cap_op
	var op = ">" if layers.island.cap_op else "<"
	islandcapOpBt.set_text(op)
	generate_islands()


func _on_IslandButton_pressed():
	_set_values("island")
	generate_islands()


func _on_IslandClear_pressed():
	tilemapIslands.clear()


func _on_Randomize_pressed():
	noise.seed = randi()
	
	for l in layers.values():
		l.noise.seed = randi()
	
	generate_map()


func _on_RiverButton2_pressed():
	generate_rivers()


func _on_TreeButton_pressed():
	_set_values("tree")
	generate_trees()


func _on_TreeClear_pressed():
	tilemapTree.clear()
