class_name CVPlayer
extends KinematicBody2D

export (int) var MAX_SPEED = 300
export (int) var MAX_JUMP = 400
export (int) var MIN_JUMP = 300
export (int) var FLOOR_ACC = 64
export (int) var FLOOR_FRICTION = 16
export (int) var AIR_ACC = 32
export (int) var GRAVITY = 16
export (int) var AIR_FINAL_SPEED = 1100
export (int) var COYOTE_JUMP_FRAMES = 7
export (int) var DASH_SPEED = 700
export (int) var DASH_FRAMES
export (int) var MAX_MULTIJUMP = 0
export (int) var WALLSLIDE_SPEED = 100
export (int) var WALLJUMP_FRAMES = 10
export (int) var AIR_MOMENTUM_FRAMES = 10

enum {DASH, WALLJUMP}
export (int, FLAGS, "Dash", "Walljump") var SKILLS = 0

func has_skill(skill):
	return SKILLS & (1 << skill)

onready var max_speed = MAX_SPEED
onready var gravity = GRAVITY
onready var air_final_speed = AIR_FINAL_SPEED
onready var max_jump = MAX_JUMP
onready var min_jump = MIN_JUMP
onready var floor_acc = FLOOR_ACC
onready var floor_friction = FLOOR_FRICTION
onready var air_acc = AIR_ACC
onready var dash_speed = DASH_SPEED
onready var max_multijump = MAX_MULTIJUMP
onready var wallslide_speed = WALLSLIDE_SPEED

onready var sm = $States
onready var inputHelper = $Inputs
onready var sprite = $Sprite
onready var animPlayer = $Anims/Base
onready var animTree = $AnimationTree
onready var animState = animTree.get('parameters/playback')

onready var debugVelocity = $CanvasLayer/Debug/Velocity
onready var debugState = $CanvasLayer/Debug/StateQueue

var has_control = true
var ori = 1

var velocity = Vector2.ZERO
var velocity_jump = 0
var velocity_move = 0

var floor_jump = false
var multijump = 0

var last_input_dir_vector = Vector2.ZERO
var last_velocity_move_sign # Used mainly in walljumpsies
var dash_input: Vector2

var can_dash = true
var gravity_on = true

var inputs = {
	dirv = Vector2.ZERO,
	jump_p = 0,
	jump_jp = 0,
	jump_jr = 0,
	dash = 0,
	aux = 0,
}

onready var cooldowns = {
	"coyote": {
		max_value = COYOTE_JUMP_FRAMES,
		value = COYOTE_JUMP_FRAMES
	},
	"dash": {
		max_value = DASH_FRAMES,
		value = DASH_FRAMES
	},
	"walljump": {
		max_value = WALLJUMP_FRAMES,
		value = WALLJUMP_FRAMES
	},
	"air_momentum": {
		max_value = AIR_MOMENTUM_FRAMES,
		value = AIR_MOMENTUM_FRAMES
	},
}


func _ready():
	sm.init(self, "Idle")
	inputHelper.init(self)
	
	
func _physics_process(delta):
	if has_control:
		inputHelper.get_inputs()
	
	update_cooldowns()
	sm.run(delta)
	apply_velocity(delta)
	
	update_debug()


func apply_jump(strength := max_jump + gravity, is_floor_jump := false):
	velocity_jump = -(strength)
	floor_jump = is_floor_jump


func apply_velocity(_delta):
	var _snaps = [Vector2(0, 16), Vector2(16, 0), Vector2(0, -16), Vector2(-16, 0)]
	var floor_normals = [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]

	if sm.state_curr == "Walljump":
		if ori != -last_velocity_move_sign:
			change_ori(-last_velocity_move_sign)
	else:
		change_ori(sign(inputs.dirv.x))
	
	if gravity_on:
		velocity_jump = approach(velocity_jump, air_final_speed, gravity)

	velocity.x = velocity_move
	velocity.y = velocity_jump

	velocity = move_and_slide(velocity, floor_normals[0])


func setup_state_queue(state):
	debugState.set_text("%s <= %s" % [state, debugState.get_text()])


func update_debug():
	debugVelocity.set_text("(%5d, %5d)" % [velocity.x, velocity.y])


func change_ori(_ori):
	if(ori != _ori and _ori != 0):
		ori = _ori
		self.scale.x *= -1
		if sm.state_curr == "Idle" or sm.state_curr == "Move":
			animState.travel("MoveTurn")


func update_cooldowns():
	for cd in cooldowns.values():
		cd.value = min(cd.value + 1, cd.max_value)


func approach(a, b, amount):
	if (a < b):
		a += amount
		if (a > b):
			return b
	else:
		a -= amount
		if(a < b):
			return b
	return a
