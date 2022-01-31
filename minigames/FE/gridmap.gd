extends TileMap

onready var Game = get_parent()
onready var preview = $Preview
onready var selection = $Area
onready var selection_col = $Area/col
onready var pathway = $pathway

var astar = AStar2D.new()
var unit_selected: Unit

var DIRS = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT,
]

var unit_map = {}
func get_unit_id(pos: Vector2):
	return (pos.x * 100) + pos.y

func _process_preview(_delta, pos):
	if preview.visible:
		selection.global_position = snap_to_grid(pos)
		if is_walkable_pos(pos):
			if preview.global_position != pos:
				pathway.clear()
				var unit_id = get_unit_id(world_to_map(unit_selected.global_position))
				var path = astar.get_point_path(unit_id, get_unit_id(world_to_map(pos)))
				for p in path:
					pathway.set_cellv(p, 1)
					pathway.update_bitmask_area(p)
			preview.global_position = snap_to_grid(pos)
			

func update_map():
	var units = get_tree().get_nodes_in_group(Unit.GROUP)
	for u in units:
		if not unit_map.has(world_to_map(u.global_position)):
			unit_map[world_to_map(u.global_position)] = u
			
	print_debug(unit_map)

func update_unit_pos(old, new, faction):
	if old == new:
		var unit = unit_map.get(old)
		if unit_map.erase(old):
			unit_map[new] = unit

func show_preview(pos):
	preview.global_position = snap_to_grid(pos)
	preview.visible = true
	selection_col.disabled = false
	
func hide_preview():
	preview.visible = false
	selection_col.disabled = true

func get_entity_at_selection():
	var entities = selection.get_overlapping_areas()
	if entities and entities[0] is Unit:
		return entities[0]
		
func get_unit_at_map(pos: Vector2) -> Unit:
	return unit_map.get(pos)

func snap_to_grid(pos: Vector2) -> Vector2:
	return map_to_world(world_to_map(pos), true) + (cell_size / 2)

func is_walkable_pos(pos: Vector2) -> bool:
	return true if get_cellv(world_to_map(pos)) == 1 else false

func is_walkable_cell(cell: Vector2) -> bool:
	return true if get_cellv(cell) == 1 else false

func show_walkable_cells(unit: Unit):
	unit_selected = unit
	var pos = unit.global_position
	show_preview(pos)
	
	# recursive
	make_walkable(world_to_map(pos), unit.movement)
	return
	
	# queue
	var q = [[pos, unit.movement]]
	var depth = unit.movement
	
	while not q.empty():
		# print_debug(q)
		# yield(get_tree(), "idle_frame")
		var f = q.pop_back()
		var p = f[0]
		var d = f[1]
		
		if d == 1:
			for dir in DIRS:
				var pos_with_dir = p + dir
				if get_cellv(pos_with_dir) == -1:
					set_cellv(pos_with_dir, 2)
			continue
		if get_cellv(p) == 1:
			continue
			
		var u = get_unit_at_map(p)
		if u:
			if u.faction == Unit.HOSTILE:
				set_cellv(p, 2)
				continue
				
		set_cellv(p, 1)
		astar.add_point(get_unit_id(p), p)
		
		for dir in DIRS:
			var pos_with_dir = p + dir
			astar.add_point(get_unit_id(pos_with_dir), pos_with_dir)
			
			astar.connect_points(get_unit_id(p), get_unit_id(pos_with_dir))
			
			q.push_back([pos_with_dir, d - 1])

func make_walkable(pos: Vector2, depth: int, last_dir := Vector2.ZERO):
	yield(get_tree().create_timer(0.001), "timeout")
	if depth == 0:
		return
	
	if get_cellv(pos) == 1:
		return
	
	var unit = get_unit_at_map(pos)
	if unit:
		if unit.faction == Unit.HOSTILE:
			return
		
	set_cellv(pos, 1)
	astar.add_point((pos.x * 100) + pos.y, pos)
	
	for dir in DIRS:
		var pos_with_dir = pos + dir
		if get_cellv(pos_with_dir) == -1:
			set_cellv(pos_with_dir, 2)
		#if dir == last_dir:
		#	continue
		astar.add_point((pos_with_dir.x * 100) + pos_with_dir.y, pos_with_dir)
		
		astar.connect_points(get_unit_id(pos), get_unit_id(pos_with_dir))
		
		make_walkable(pos_with_dir, depth - 1, dir)

func clear_walkable():
	unit_selected = null
	hide_preview()
	for t in get_used_cells_by_id(1):
		set_cellv(t, -1)
	for t in get_used_cells_by_id(2):
		set_cellv(t, -1)
	astar.clear()
	pathway.clear()
