extends Node

var stateMachine = null
onready var p: CVPlayer

func begin():
	p.animPlayer.play("RESET")
	p.floor_jump = false
	p.animState.travel("Idle")

func run(_delta):
	if not p.is_on_wall():
		p.velocity_move = p.approach(p.velocity_move, 0, p.floor_friction)
	else:
		p.velocity_move = 0
	p.can_dash = true
	
	if p.is_on_floor():
		p.velocity_jump = 0
	
	if p.inputs.dash:
		p.cooldowns.dash.value = 0
		p.dash_input = Vector2.ZERO
		end("Dash")
	elif p.inputs.jump_jp:
		p.apply_jump(p.max_jump + p.gravity, true)
		end("Air")
	elif p.inputs.dirv.x != 0 and not p.is_on_wall():
		end("Move")
	elif not p.is_on_floor():
		p.cooldowns.coyote.value = 0
		end("Air")

func end(next_state):
	stateMachine.change_state(next_state)
