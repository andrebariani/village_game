extends Area2D

signal tile_selected

onready var Game = get_parent()

var hovered_unit: Unit
var selected_unit: Unit

var input := Vector2.ZERO
var last_input := Vector2.ZERO

enum {
	FREE,
	MOVE
}

var state = FREE

func _process(delta):
	
	match state:
		FREE:
			_handle_input()
			
			if input != last_input:
				global_position += 8 * input
				
			last_input = input

			if Input.is_action_just_released("ui_accept") and hovered_unit:
				change_state(MOVE)
				Game.unit_map.show_walkable_cells(hovered_unit)
				selected_unit = hovered_unit
		MOVE:
			_handle_input()
			
			if input != last_input and can_walk():
				global_position += 8 * input
			
			last_input = input
			
			if Input.is_action_just_released("ui_cancel"):
				change_state(FREE)
				Game.unit_panel.hide_panel()
				Game.unit_map.clear_walkable()
				selected_unit = null


func can_walk():
	return Game.unit_map.is_walkable_pos(global_position + (8*input))


func _handle_input():
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")


func change_state(_state):
	if _state != state:
		state = _state


func _on_FECursor_area_entered(area):
	if area is Unit:
		hovered_unit = area
		Game.unit_panel._setup_panel(hovered_unit)


func _on_FECursor_area_exited(area):
	match state:
		FREE:
			hovered_unit = null
			Game.unit_panel.hide_panel()
		MOVE:
			if not get_overlapping_areas():
				print_debug(str(get_overlapping_areas()))
				hovered_unit = null
				Game.unit_panel._setup_panel(selected_unit)
