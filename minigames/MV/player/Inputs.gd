extends Node

var player: CVPlayer

func init(_entity):
	self.player = _entity

func get_inputs():
	# Reset inputs
	for i in player.inputs.keys():
		if player.inputs[i] is int:
			player.inputs[i] = 0
	
	player.last_input_dir_vector = player.inputs.dirv
	
	player.inputs.dirv.x = Input.get_axis("ui_left", "ui_right")
	player.inputs.dirv.y = Input.get_axis("ui_up", "ui_down")
	
	if Input.is_action_pressed("ui_accept"):
		player.inputs.jump_p = 1
	
	if Input.is_action_just_pressed("ui_accept"):
		player.inputs.jump_jp = 1
	
	if Input.is_action_just_released("ui_accept"):
		player.inputs.jump_jr = 1
	
	if Input.is_action_just_pressed("ui_cancel") and player.has_skill(player.DASH):
		player.inputs.dash = 1
		
	if Input.is_action_pressed("aux"):
		player.inputs.jump_p = 1
