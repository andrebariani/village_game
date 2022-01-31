extends Node

var stateMachine = null
var p: CVPlayer

func begin():
	p.animPlayer.play("RESET")
	if p.cooldowns.air_momentum.value == p.cooldowns.air_momentum.max_value:
		if p.floor_jump and stateMachine.state_last != "Dash":
			p.animState.start("Jump")
		else:
			p.animState.start("Fall")

func run(_delta):
	var dir = p.inputs.dirv
	
	if p.cooldowns.air_momentum.value != p.cooldowns.air_momentum.max_value:
		if p.cooldowns.air_momentum.value > p.cooldowns.air_momentum.max_value / 3 \
				and dir.x == (p.last_velocity_move_sign):
			p.cooldowns.air_momentum.value = p.cooldowns.air_momentum.max_value
			p.velocity_move = p.approach(p.velocity_move, p.max_speed * dir.x, p.air_acc)
		else:
			p.velocity_move = p.approach(p.velocity_move, p.max_speed *  \
				-p.last_velocity_move_sign, p.air_acc)
	else:
		p.velocity_move = p.approach(p.velocity_move, p.max_speed * dir.x, p.air_acc)
	
	if p.inputs.jump_jp:
		if p.cooldowns.coyote.value < p.cooldowns.coyote.max_value:
			p.apply_jump(p.max_jump)
		elif p.multijump != 0:
			p.apply_jump(p.max_jump)
			p.multijump -= 1
	
	if p.inputs.jump_jr:
		if(p.velocity_jump  < -p.min_jump):
			p.velocity_jump = -p.min_jump
	
	if p.is_on_ceiling():
		p.velocity_jump = 0
	
	if p.inputs.dash and p.can_dash:
		p.cooldowns.dash.value = 0
		p.dash_input = dir
		stateMachine.change_state("Dash")
	elif p.has_skill(p.WALLJUMP) and p.is_on_wall() and \
				p.get_last_slide_collision().get_normal().x != dir.x and \
			 	dir.x != 0 and p.velocity_jump > -90:
		p.velocity_jump = 0
		p.last_velocity_move_sign = sign(p.velocity_move)
		p.cooldowns.walljump.value = 0
		stateMachine.change_state("Walljump")
	elif p.is_on_floor():
		p.velocity_jump = 0
		p.multijump = p.max_multijump
		if p.velocity_move == 0:
			stateMachine.change_state("Idle")
		else:
			stateMachine.change_state("Move")
