extends Node2D


export var SCROLL_SPEED = 2
onready var tilemap = $TileMap
onready var camera = $Camera2D


func _input(event):
	if event is InputEventMouseButton:
		tilemap.set_cellv(tilemap.world_to_map(event.position), 1)
	

func _process(delta):
	var scroll_dir = Vector2.ZERO
	scroll_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	scroll_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	camera.position += scroll_dir * SCROLL_SPEED
