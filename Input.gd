extends Node2D


export var SCROLL_SPEED = 2
onready var tilemapBuildings = $Buildings
onready var tilemapRoads = $Roads
onready var camera = $Camera2D


var zoom = true
var scroll_multi = 1


func _process(_delta):
	
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
	
	
	
