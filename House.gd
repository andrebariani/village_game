extends "res://Building.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var x = randi() % 10
	var rect = Rect2(48 + x*16, 64, 16, 16)
	$Sprite.region_rect = rect
	print_debug($Sprite.region_rect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
