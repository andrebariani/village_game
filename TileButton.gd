extends Button
class_name TileButton

signal selected()

onready var tile_name = self.name
export(PackedScene) var building_file
export var repeatable = false


func _ready():
	set_text(tile_name)
	self.connect("toggled", self, "_on_Button_toggled")


func _on_Button_toggled(_button_pressed):
	if _button_pressed:
		emit_signal("selected")
