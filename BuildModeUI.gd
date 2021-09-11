extends Control

onready var tooltip = $HBoxContainer/BuildingToolTip
onready var checkboxes = $HBoxContainer/GridContainer
onready var buildingMap = get_node("/root/Node2D/Buildings")
onready var roadMap = get_node("/root/Node2D/Roads")


var selected_tile = null


func _ready():
	for box in checkboxes.get_children():
		box.connect("selected", self, "_on_button_selected", [box])


func _process(_delta):
	if selected_tile:
		if selected_tile.tile_name == "Road":
			if Input.is_action_pressed("ui_accept"):
				var clicked_cell = roadMap.world_to_map(get_global_mouse_position())
				print_debug(clicked_cell)
				roadMap.set_cellv(clicked_cell, 1)
				roadMap.update_bitmask_area(clicked_cell)
			if Input.is_action_pressed("delete"):
				var clicked_cell = roadMap.world_to_map(get_global_mouse_position())
				print_debug(clicked_cell)
				roadMap.set_cellv(clicked_cell, -1)
				roadMap.update_bitmask_area(clicked_cell)


func _on_button_mouse_in(tile):
	tooltip.visible = true
	tooltip.set_tooltip(tile)


func _on_button_mouse_out(tile):
	tooltip.visible = false


func _on_button_selected(tile):
	selected_tile = tile
	if tile.tile_name == 'Road' or tile.tile_name == 'Delete':
		return
	var instanced_file = tile.building_file.instance()
	buildingMap.add_child(instanced_file)
	instanced_file.connect("placed", self, "_on_tile_placed", [tile])
	
	
func _on_tile_placed(tile):
	if not selected_tile.repeatable:
		self.selected_tile.pressed = false
		self.selected_tile = null


func _on_GridContainer_mouse_entered():
	print_debug("hi")


func _on_GridContainer_mouse_exited():
	print_debug("bye")
