extends Node2D
class_name Building

onready var map = get_parent()
onready var icon = $Sprite
onready var ui = get_tree().get_nodes_in_group("MainUI")[0]


export var title = "title"
export var desc = "desc"

signal placed()

enum MODE {
	PREVIEW,
	PLACED
}
var mode = MODE.PREVIEW

var tile = Vector2.ZERO

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
					tile = map.world_to_map(get_global_mouse_position())
		MODE.PLACED:
			pass
	


func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if ui.selected_tile and ui.selected_tile.tile_name == "Delete":
			queue_free()
