extends Node2D

@onready var belt_scn = preload("res://scenes/belts/belt.tscn")
@onready var player = get_node("../../player")
@onready var ref = get_node("../../ref_belt")
var highlight
var highlight_belts = []
var highlight_cells = []
var highlight_start_cell = null
var highlight_end_cell = null
var highlight_initial_dir = null

var tile_size = 16
var rot = 0
var tiles = {}

var last_cell = Vector2(-9999,9999)

func _ready():
	highlight = create_highlight_belt()
	
func create_highlight_belt() -> Belt:
	var highlight_belt = belt_scn.instantiate()
	highlight_belt.modulate = Color(0.31, 1.00, 0.44, 1)
	highlight_belt.set_type(Types.Belt_Type.STRAIGHT, 0, false, ref)
	highlight_belt.z_index = 1
	add_child(highlight_belt)
	return highlight_belt
	
func _process(delta):
	var cell = get_hovered_cell()
	if cell != last_cell:
		place_belt(cell, true)
	last_cell = cell

	if Input.is_action_just_pressed("rotate"):
		rot += 90
		if rot >= 360:
			rot = 0
		highlight.rotation_degrees = rot
		place_belt(cell, true)

	if Input.is_action_just_released("place"):
#		place_belt(cell, false)
		highlight.visible = true
		highlight_start_cell = null
		highlight_initial_dir = null
		for belt in highlight_belts:
			belt.queue_free()
		highlight_belts = []
		highlight_cells = []
		
	if Input.is_action_just_released("cancel"):
		highlight.visible = true
		highlight_start_cell = null
		highlight_initial_dir = null
		for belt in highlight_belts:
			belt.queue_free()
		highlight_belts = []
		highlight_cells = []
		
	if Input.is_action_just_pressed("place"):
		highlight_start_cell = cell
		highlight_initial_dir = null
		highlight.visible = false
		
	if Input.is_action_pressed("place") and highlight_start_cell != null:
		if cell != highlight_end_cell:
			highlight_end_cell = cell
			for belt in highlight_belts:
				belt.queue_free()
			highlight_belts = []
			highlight_cells = []
			
			if cell != highlight_start_cell:
				if highlight_initial_dir == null:
					if cell.x > highlight_start_cell.x:
						highlight_initial_dir = Types.Direction.RIGHT
					elif cell.x < highlight_start_cell.x:
						highlight_initial_dir = Types.Direction.LEFT
					elif cell.y > highlight_start_cell.y:
						highlight_initial_dir = Types.Direction.DOWN
					elif cell.y < highlight_start_cell.y:
						highlight_initial_dir = Types.Direction.UP
				
				if highlight_initial_dir != null:
					match highlight_initial_dir:
						Types.Direction.RIGHT:
							if cell.x < highlight_start_cell.x:
								highlight_initial_dir = Types.Direction.LEFT
						Types.Direction.LEFT:
							if cell.x > highlight_start_cell.x:
								highlight_initial_dir = Types.Direction.RIGHT
						Types.Direction.DOWN:
							if cell.y < highlight_start_cell.y:
								highlight_initial_dir = Types.Direction.UP
						Types.Direction.UP:
							if cell.y > highlight_start_cell.y:
								highlight_initial_dir = Types.Direction.DOWN
					match highlight_initial_dir:
						Types.Direction.RIGHT:
							for i in range(highlight_start_cell.x, cell.x + 1, 16):
								highlight_cells.append(Vector2(i, highlight_start_cell.y))
						Types.Direction.LEFT:
							for i in range(highlight_start_cell.x, cell.x - 1, -16):
								highlight_cells.append(Vector2(i, highlight_start_cell.y))
						Types.Direction.DOWN:
							for i in range(highlight_start_cell.y, cell.y + 1, 16):
								highlight_cells.append(Vector2(highlight_start_cell.x, i))
						Types.Direction.UP:
							for i in range(highlight_start_cell.y, cell.y - 1, -16):
								highlight_cells.append(Vector2(highlight_start_cell.x, i))
					
					if highlight_cells.size() > 0:
						var corner_cell = highlight_cells[-1]
						var corner_direction = null
						var turning_index = highlight_cells.size() - 1
						
						if cell.x > corner_cell.x:
							corner_direction = Types.Direction.RIGHT
							for i in range(corner_cell.x + 16, cell.x + 1, 16):
									highlight_cells.append(Vector2(i, corner_cell.y))
						elif cell.x < corner_cell.x:
							corner_direction = Types.Direction.LEFT
							for i in range(corner_cell.x - 16, cell.x - 1, -16):
									highlight_cells.append(Vector2(i, corner_cell.y))
						elif cell.y > corner_cell.y:
							corner_direction = Types.Direction.DOWN
							for i in range(corner_cell.y + 16, cell.y + 1, 16):
									highlight_cells.append(Vector2(corner_cell.x, i))
						elif cell.y < corner_cell.y:
							corner_direction = Types.Direction.UP
							for i in range(corner_cell.y - 16, cell.y - 1, -16):
									highlight_cells.append(Vector2(corner_cell.x, i))
						
						for i in range(highlight_cells.size()):
							var current_highlight = create_highlight_belt();
							var match_dir = 0
							if i <= turning_index:
								match_dir = highlight_initial_dir
							else:
								match_dir = corner_direction
							var angle = 0
							match match_dir:
								Types.Direction.RIGHT:
									angle = 90
								Types.Direction.DOWN:
									angle = 180
								Types.Direction.LEFT:
									angle = 270
									
							var highlight_belt_type = Types.Belt_Type.STRAIGHT
							var highlight_flipped = false
							if i == turning_index and i != highlight_cells.size()-1:
								highlight_belt_type = Types.Belt_Type.CORNER
								if ((highlight_initial_dir == Types.Direction.UP and corner_direction == Types.Direction.LEFT) 
									or (highlight_initial_dir == Types.Direction.RIGHT and corner_direction == Types.Direction.UP)
									or (highlight_initial_dir == Types.Direction.DOWN and corner_direction == Types.Direction.RIGHT) 
									or (highlight_initial_dir == Types.Direction.LEFT and corner_direction == Types.Direction.DOWN)):
										highlight_flipped = true
							current_highlight.set_type(highlight_belt_type, angle, highlight_flipped, ref)
							current_highlight.position = highlight_cells[i]
							highlight_belts.append(current_highlight)
			else:
				highlight_cells.append(highlight_start_cell)
				var current_highlight = create_highlight_belt();
				current_highlight.set_type(Types.Belt_Type.STRAIGHT, rot, false, ref)
				current_highlight.position = cell
				highlight_belts.append(current_highlight)

func get_hovered_cell() -> Vector2:
	var m_pos = get_global_mouse_position()
	var cell_x = snappedi(m_pos.x, tile_size)
	var cell_y = snappedi(m_pos.y, tile_size)

	var highlighted = Vector2(cell_x, cell_y)
	highlight.position = highlighted
	return highlighted

func place_belt(cell: Vector2, highlight_only: bool):
	var map_x = cell.x / tile_size
	var map_y = cell.y / tile_size

	var belts = get_surrounding_belts(Vector2(map_x, map_y))
	var has_up = belts.has(Types.Direction.UP)
	var has_down = belts.has(Types.Direction.DOWN)
	var has_left = belts.has(Types.Direction.LEFT)
	var has_right = belts.has(Types.Direction.RIGHT)

	var base = has_down
	var top = has_up
	var adj_left = has_left
	var adj_right = has_right
	
	var base_dir = Types.Direction.DOWN
	var top_dir = Types.Direction.UP
	var adj_left_dir = Types.Direction.LEFT
	var adj_right_dir = Types.Direction.RIGHT

	match rot:
		90:
			base = has_left
			top = has_right
			adj_left = has_up
			adj_right = has_down
			base_dir = Types.Direction.LEFT
			top_dir = Types.Direction.RIGHT
			adj_left_dir = Types.Direction.UP
			adj_right_dir = Types.Direction.DOWN
		180:
			base = has_up
			top = has_down
			adj_left = has_right
			adj_right = has_left
			base_dir = Types.Direction.UP
			top_dir = Types.Direction.DOWN
			adj_left_dir = Types.Direction.RIGHT
			adj_right_dir = Types.Direction.LEFT
		270:
			base = has_right
			top = has_left
			adj_left = has_down
			adj_right = has_up
			base_dir = Types.Direction.RIGHT
			top_dir = Types.Direction.LEFT
			adj_left_dir = Types.Direction.DOWN
			adj_right_dir = Types.Direction.UP

	var belt_type = Types.Belt_Type.STRAIGHT
	var belt_flipped = false
	var belt_rot = rot

	if !base or !belts[base_dir].output.has(get_opposite_dir(base_dir)):
		if adj_right:
			var right_belt = belts[adj_right_dir]
			if right_belt.output.has(get_opposite_dir(adj_right_dir)):
				belt_type = Types.Belt_Type.CORNER
				belt_rot = rotate_ccw(belt_rot)
		elif adj_left:
			var left_belt = belts[adj_left_dir]
			if left_belt.output.has(get_opposite_dir(adj_left_dir)):
				belt_type = Types.Belt_Type.CORNER
				belt_flipped = true
				belt_rot = rotate_cw(belt_rot)

	if highlight_only:
		highlight.set_type(belt_type, belt_rot, belt_flipped, ref)
	else:
		var belt = create_belt(cell, belt_type, belt_flipped, ref, belt_rot)

		if !tiles.has(map_x):
			tiles[map_x] = {}

		if tiles[map_x].has(map_y):
			var old_belt = tiles[map_x][map_y]
			old_belt.queue_free()
		tiles[map_x][map_y] = belt
		# Update surrounding belts that need updating

func get_surrounding_belts(cell: Vector2) -> Dictionary:
	var belts = {}

	if tiles.has(cell.x):
		if (tiles[cell.x].has(cell.y-1)):
			belts[Types.Direction.UP] = tiles[cell.x][cell.y-1]
		if (tiles[cell.x].has(cell.y+1)):
			belts[Types.Direction.DOWN] = tiles[cell.x][cell.y+1]
	if (tiles.has(cell.x-1) and tiles[cell.x-1].has(cell.y)):
		belts[Types.Direction.LEFT] = tiles[cell.x-1][cell.y]
	if (tiles.has(cell.x+1) and tiles[cell.x+1].has(cell.y)):
		belts[Types.Direction.RIGHT] = tiles[cell.x+1][cell.y]
	return belts

func create_belt(cell: Vector2, belt_type: Types.Belt_Type, is_flipped: bool, ref: AnimatedSprite2D, belt_rot: int) -> Belt:
	var inst = belt_scn.instantiate()
	inst.set_type(belt_type, belt_rot, is_flipped, ref)
	inst.position = cell
	add_child(inst)
	inst.set_frame_and_progress(ref.get_frame(), ref.get_frame_progress())
	return inst
	
func get_opposite_dir(dir: Types.Direction) -> Types.Direction:
	match dir:
		Types.Direction.DOWN:
			return Types.Direction.UP
		Types.Direction.UP:
			return Types.Direction.DOWN
		Types.Direction.LEFT:
			return Types.Direction.RIGHT
		Types.Direction.RIGHT:
			return Types.Direction.LEFT
	return Types.Direction.UP
	
func rotate_cw(in_rot: int) -> int:
	var out_rot = in_rot + 90
	if out_rot >= 360:
		out_rot = 0
	return out_rot
	
func rotate_ccw(in_rot: int) -> int:
	var out_rot = in_rot - 90
	if in_rot < 90:
		out_rot = 270
	return out_rot
