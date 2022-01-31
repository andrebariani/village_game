extends Node

var stateMachine = null
var p = null

func begin():
	p.animPlayer.play("RESET")
	p.gravity_on = false
	p.animState.start("Wallslide")

func run(_delta):
	var dir = p.inputs.dirv
	
	p.velocity_jump = p.approach(p.velocity_jump, p.wallslide_speed, p.gravity * 0.8)
	# p.velocity_jump = 0
	
	p.floor_jump = false
	p.can_dash = true
	
	if p.last_velocity_move_sign != dir.x or dir.x == 0:
		if p.cooldowns.walljump.value == p.cooldowns.walljump.max_value:
			p.velocity_move = 0
			end("Air")
			return
	else:
		p.cooldowns.walljump.value = 0
	
	if p.is_on_floor():
		p.velocity_jump = 0
		end("Idle")
	elif p.inputs.dash:
		p.cooldowns.dash.value = 0
		p.dash_input = dir
		end("Dash")
	elif p.inputs.jump_jp:
		p.apply_jump(p.max_jump + 50)
		p.velocity_move = p.last_velocity_move_sign * -1 * (p.max_speed)
		p.cooldowns.air_momentum.value = 0
		p.animState.travel("Walljump")
		end("Air")
	elif not p.is_on_wall():
		p.velocity_move = 0
		end("Air")


func end(next_state):
	p.gravity_on = true
	stateMachine.change_state(next_state)
