extends Area2D

onready var player: CVPlayer

func ready():
	set_physics_process(false)

func _physics_process(_delta):
	if player:
		player.velocity.x += 100

func _on_Wind_body_entered(body):
	if body is CVPlayer:
		player = body
		set_physics_process(true)

func _on_Wind_body_exited(body):
	if body is CVPlayer:
		set_physics_process(false)
