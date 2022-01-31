extends Node

var stateMachine = null
onready var p: CVPlayer

func begin():
	p.animPlayer.play("RESET")
	p.floor_jump = false
	p.animState.travel("Move")

func run(_delta):
	var dir = p.inputs.dirv
	#if p.inputs.sprint:
	#	p.max_speed = p.MAX_SPEED + 200
	#else: 
	#	p.max_speed = p.MAX_SPEED
	
	p.velocity_move = p.approach(p.velocity_move, p.max_speed * dir.x, p.floor_acc)
	
	if p.is_on_floor():
		p.velocity_jump = 0
	
	p.can_dash = true
	if p.inputs.dash:
		p.cooldowns.dash.value = 0
		p.dash_input = dir
		end("Dash")
	if p.inputs.jump_jp:
		p.apply_jump(p.max_jump + p.gravity, true)
		end("Air")
	elif not p.is_on_floor():
		p.cooldowns.coyote.value = 0
		end("Air")
	elif dir.x == 0:
		end("Idle")
		
	
func end(next_state):
	stateMachine.change_state(next_state)
