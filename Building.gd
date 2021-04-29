extends Node2D
class_name Building

onready var map = get_parent()

signal placed()

enum MODE {
	PREVIEW,
	PLACED
}
var mode = MODE.PREVIEW


func _ready():
	$Area2D/CollisionShape2D.shape.extents -= Vector2(1,1) 


func _process(_delta):
	match mode:
		MODE.PREVIEW:
			global_position = map.map_to_world(map.world_to_map(get_global_mouse_position()))
			if $Area2D.get_overlapping_areas():
				$Sprite.modulate = Color("#ff0000")
			else:
				$Sprite.modulate = Color("#fff")
				if Input.is_action_just_pressed("ui_accept"):
					emit_signal("placed")
					mode = MODE.PLACED
		MODE.PLACED:
			pass
	
