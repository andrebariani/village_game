class_name Unit
extends Area2D

export (String) var title = "Class"
enum {PLAYER, HOSTILE}
export(int, "Player", "Hostile") var faction = PLAYER setget set_faction

export (String) var unit_class = "Archer"

export (int) var attack = 0
export (int) var defense = 0
export (int) var movement = 6

const GROUP := 'Units'

onready var icon := $Icon
onready var sprite := $Sprite
onready var act_menu := $ActMenu
onready var anim: AnimationPlayer = $anim
onready var ai_player = $AI/Player
onready var ai_hostile = $AI/Hostile
onready var stage: Stage
onready var tween := Tween.new()
onready var target: Unit


enum {
	READY,
	MOVE,
	ACT,
	ATTACK
	DONE,
	TWEEN
}

var anims = [
	"idle",
	"selected",
	"move",
	"done"
]

var state = READY
var confirm_delay_max = 9
var confirm_delay = 9
var hover := false

var tile: Vector2
var original_tile: Vector2

func _ready():
	add_child(tween)
	connect("mouse_entered", self, "_on_Unit_mouse_entered")
	connect("mouse_exited", self, "_on_Unit_mouse_exited")
	tween.connect("tween_completed", self, "_on_tween_completed")
	self.add_to_group(GROUP)

func set_faction(_faction):
	match _faction:
		PLAYER:
			if sprite:
				sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
				sprite.flip_h = false
		HOSTILE:
			if sprite:
				sprite.self_modulate = Color("ff1a1a")
				sprite.flip_h = true
				
	faction = _faction

func _physics_process(delta):
	match faction:
		PLAYER:
			ai_player.run(delta, self)
		HOSTILE:
			ai_hostile.run(delta, self)


func play_anim(_anim: String):
	if anim.current_animation != _anim:
		anim.play(_anim)


func position_unit():
	global_position = stage.unit_map.snap_to_grid(get_global_mouse_position())
	tile = stage.unit_map.world_to_map(global_position)


func _attack():
	print_debug(self.title + " attacked " + target.title + "!")
	_done()
	
func _done():
	act_menu.visible = false
	stage.unit_map.unit_selected = false
	stage.unit_map.update_unit_pos(original_tile, global_position, faction)
	change_state(DONE)

func return_to_origin():
	tween.interpolate_property(self, "global_position", global_position, \
					original_tile, 0.4, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
	change_state(TWEEN)


func change_state(_state):
	if _state != state:
		state = _state

func set_stage(_stage):
	stage = _stage

func _on_Unit_mouse_entered():
	stage.unit_panel._setup_panel(self)
	if not stage.unit_map.unit_selected:
		hover = true

func _on_Unit_mouse_exited():
	# stage.unit_panel.hide_panel()
	hover = false

func _on_tween_completed(_object, _key):
	change_state(READY)

func _on_Wait_button_up():
	_done()

func _on_Attack_button_up():
	change_state(ATTACK)
