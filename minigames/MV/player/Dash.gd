extends Node

var stateMachine = null
var p: CVPlayer

func begin():
	p.animPlayer.play("RESET")
	p.has_control = false
	p.gravity_on = false
	p.animState.start("Dash")

func run(_delta):
	p.can_dash = false
	
	if p.dash_input.x != 0:
		p.velocity_move = p.dash_speed * p.dash_input.x
		p.velocity_jump = (p.dash_speed * 0.5) * p.dash_input.y
	else:
		p.velocity_move = p.dash_speed * p.ori
		p.velocity_jump = 0
	
	if p.is_on_wall() and p.get_last_slide_collision().get_normal().x != p.ori:
		p.cooldowns.dash.value = p.cooldowns.dash.max_value
		if p.has_skill(p.WALLJUMP):
			if not p.is_on_floor():
				p.last_velocity_move_sign = sign(p.velocity_move)
				p.cooldowns.walljump.value = 0
				end("Walljump")
			else:
				end("Idle")
		else:
			end("Air")
	elif p.cooldowns.dash.value == p.cooldowns.dash.max_value:
		if p.is_on_floor():
			p.velocity_jump = 0
			end("Move")
		else:
			end("Air")


func end(next_state: String):
	p.has_control = true
	p.gravity_on = true
	stateMachine.change_state(next_state)
