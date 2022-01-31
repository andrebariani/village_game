class_name Stage
extends YSort

onready var unit_map = $gridmap
# onready var cursor = $FECursor
onready var unit_panel = $Control
onready var units = $Units

var players = []
var hostile = []

func _ready():
	for unit in units.get_children():
		unit.set_stage(self)
		match unit.faction:
			unit.PLAYER:
				players.push_back(unit)
			unit.HOSTILE:
				hostile.push_back(unit)
	unit_map.update_map()
