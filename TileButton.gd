extends Button
class_name TileButton

export var tile_name = "Tile"
export var tile_id = 0

func _ready():
	set_text(tile_name)
