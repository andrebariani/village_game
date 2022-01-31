extends Node


func run(_delta, unit: Unit):
	match unit.state:
		unit.READY:
			pass
