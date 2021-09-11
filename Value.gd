extends Label


onready var n = get_parent().get_child(1)

func _process(delta):
	self.set_text(str(n.value))
