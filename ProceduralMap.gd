extends Node2D

onready var camera = $Camera2D
onready var procUi = $Camera2D/ProcDebug/TabContainer
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
}


func _ready():
	_set_sliders()
	generate_map()
	toggle_zoom()


func generate_map():
	generate_mountains()
	generate_grass()
	generate_islands()


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
			#tilemapGround.set_cellv(Vector2(x,y), 2)
			if layer.cap_op:
				if n_cell > layer.cap:
					tilemapGround.set_cellv(Vector2(x,y), 1)
			else:
				if n_cell < layer.cap:
					tilemapGround.set_cellv(Vector2(x,y), 1)
			#tilemapGround.update_bitmask_area(Vector2(x,y))


func generate_islands():
	tilemapIslands.clear()
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
					tilemapIslands.set_cellv(Vector2(x,y), 1)
			else:
				if n_cell < layer.cap:
					tilemapIslands.set_cellv(Vector2(x,y), 1)


func _process(_delta):
	
	if Input.is_action_just_pressed("delete"):
		procUi.visible = !procUi.visible
	if Input.is_action_just_pressed("ui_select"):
		toggle_zoom()
	
	var scroll_dir = Vector2.ZERO
	scroll_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	scroll_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	camera.position += scroll_dir * SCROLL_SPEED * scroll_multi
	

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
	tilemapGround.clear()


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
	print_debug("miau")
	
	noise.seed = randi()
	
	for l in layers.values():
		l.noise.seed = randi()
	
	generate_map()
