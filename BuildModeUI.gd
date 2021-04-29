extends Control

onready var checkboxes = $GridContainer
onready var buildingMap = get_node("/root/Node2D/Buildings")
onready var roadMap = get_node("/root/Node2D/Roads")


var selected_tile = null


func _ready():
	for box in checkboxes.get_children():
		box.connect("selected", self, "_on_button_selected", [box])


func _process(_delta):
	if selected_tile:
		if Input.is_action_pressed("ui_accept"):
			if selected_tile.tile_name == "Road":
				var clicked_cell = roadMap.world_to_map(get_global_mouse_position())
				roadMap.set_cellv(clicked_cell, 0)
				roadMap.update_bitmask_area(clicked_cell)


func _on_button_selected(tile):
	selected_tile = tile
	if tile.tile_name == 'Road':
		return
	var instanced_file = tile.building_file.instance()
	buildingMap.add_child(instanced_file)
	instanced_file.connect("placed", self, "_on_tile_placed")
	
	
func _on_tile_placed():
	if not selected_tile.repeatable:
		self.selected_tile.pressed = false
		self.selected_tile = null
