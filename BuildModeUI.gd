extends Control

onready var checkboxes = $GridContainer
onready var camera = $Camera2D
onready var board = get_parent()


func _ready():
	for box in checkboxes.get_children():
		box.connect("toggled", self, "_on_Box_pressed")
		pass
	pass


func _on_Box_pressed(button_pressed):
	
