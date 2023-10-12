extends Node2D

@onready var belt_scn = preload("res://scenes/belts/belt.tscn")
@onready var player = get_node("../../player")
@onready var ref = get_node("../../ref_belt")

var tile_size = 16
var rot = 0
var tiles = {}


func _process(delta):
	var cell = get_hovered_cell()

	if Input.is_action_just_pressed("rotate"):
		rot += 90
		if rot >= 360:
			rot = 0
		ref.rotation_degrees = rot

	if Input.is_action_just_pressed("place"):
		place_belt(cell)

func get_hovered_cell() -> Vector2:
	var m_pos = get_global_mouse_position()
	var cell_x = snappedi(m_pos.x, tile_size)
	var cell_y = snappedi(m_pos.y, tile_size)

	var highlighted = Vector2(cell_x, cell_y)
	ref.position = highlighted
	return highlighted

func place_belt(cell: Vector2):
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

	if !top:
		if adj_right:
			var right_belt = belts[adj_right_dir]
			if right_belt.input.has(get_opposite_dir(adj_right_dir)):
				belt_type = Types.Belt_Type.CORNER
		elif adj_left:
			var left_belt = belts[adj_left_dir]
			if left_belt.input.has(get_opposite_dir(adj_left_dir)):
				belt_type = Types.Belt_Type.CORNER
				belt_flipped = true
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
