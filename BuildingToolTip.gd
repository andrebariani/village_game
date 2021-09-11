extends NinePatchRect


onready var image = $VBoxContainer/HBoxContainer/TextureRect
onready var title = $VBoxContainer/HBoxContainer/Title
onready var desc = $VBoxContainer/HBoxContainer/Desc


func set_tooltip(tile):
	title.set_text(tile.title)
	desc.set_text(tile.desc)
	image.set_texture(tile.icon)
