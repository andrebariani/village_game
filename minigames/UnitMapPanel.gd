extends Control

onready var unit_icon_contour = $NinePatchRect/IconContour
onready var unit_icon = $NinePatchRect/IconContour/IconPic
onready var title = $NinePatchRect/Title
onready var panel_class = $NinePatchRect/Class

onready var hide_timer = Timer.new()

func _ready():
	hide_timer.wait_time = 0.2
	hide_timer.connect("timeout", self, "_on_HideTimer_timeout")
	add_child(hide_timer)

func _setup_panel(unit: Unit):
	visible = true
	hide_timer.stop()
	unit_icon.set_texture(unit.icon.texture)
	match unit.faction:
		unit.PLAYER:
			unit_icon_contour.self_modulate = Color("90a0f6")
		unit.HOSTILE:
			unit_icon_contour.self_modulate = Color("f34242")
	title.set_text(unit.title)
	panel_class.set_text(unit.unit_class)

func hide_panel():
	hide_timer.start()

func _on_HideTimer_timeout():
	visible = false
