extends "res://Building.gd"

func _ready():
	randomize()
	var x = randi() % 10
	var rect = Rect2(24 + x*8, 32, 8, 8)
	$Sprite.region_rect = rect
	print_debug($Sprite.region_rect)
