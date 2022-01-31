extends Node

func run(delta, unit: Unit):
	match unit.state:
		unit.TWEEN:
			pass
		unit.READY:
			unit.play_anim("idle")
			
			if unit.hover and Input.is_action_just_pressed("ui_accept"):
				# confirm_delay = 0
				unit.original_tile = unit.stage.unit_map.snap_to_grid(unit.global_position)
				unit.stage.unit_map.show_walkable_cells(unit)
				unit.change_state(unit.MOVE)
		unit.MOVE:
			unit.play_anim("move")
			
			if Input.is_action_just_pressed("ui_accept"):
				unit.confirm_delay = 0
				
			unit.confirm_delay = min(unit.confirm_delay + 1, unit.confirm_delay_max)
			
			if Input.is_action_pressed("ui_accept"):
				unit.stage.unit_map._process_preview(delta, unit.get_global_mouse_position())
			
			if Input.is_action_just_released("ui_accept"):
				if unit.confirm_delay < unit.confirm_delay_max:
					var target = unit.stage.unit_map.get_entity_at_selection()
					
					if target:
						unit.target = target
						unit.change_state(unit.ACT)
					else:
						if unit.stage.unit_map.is_walkable_pos(unit.get_global_mouse_position()):
							unit.position_unit()
							unit.stage.unit_map.clear_walkable()
							unit.change_state(unit.ACT)
			
			if Input.is_action_just_pressed("ui_cancel"):
				unit.stage.unit_map.clear_walkable()
				unit.change_state(unit.READY)
		unit.ACT:
			unit.act_menu.visible = true
			if Input.is_action_just_pressed("ui_cancel"):
				unit.global_position = unit.original_tile
				unit.stage.unit_map.show_walkable_cells(unit)
				unit.act_menu.visible = false
				unit.change_state(unit.MOVE)
		unit.ATTACK:
			unit._attack()
		unit.DONE:
			unit.play_anim("idle")
			unit.sprite.self_modulate = Color("969696")
		_:
			pass
