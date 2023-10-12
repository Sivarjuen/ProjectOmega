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

	match rot:
		90:
			base = has_left
			top = has_right
			adj_left = has_up
			adj_right = has_down
		180:
			base = has_up
			top = has_down
			adj_left = has_right
			adj_right = has_left
		270:
			base = has_right
			top = has_left
			adj_left = has_down
			adj_right = has_up

	var belt_type
	var belt_flipped = false

	if !base:
		belt_type = Types.Belt_Type.START
	elif top:
		belt_type = Types.Belt_Type.STRAIGHT
	elif adj_right:
		belt_type = Types.Belt_Type.CORNER
	elif adj_left:
		belt_type = Types.Belt_Type.CORNER
		belt_flipped = true
	else:
		belt_type = Types.Belt_Type.END

	var belt = create_belt(cell, belt_type, belt_flipped, ref)

	if !tiles.has(map_x):
		tiles[map_x] = {}

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

func create_belt(cell: Vector2, belt_type: Types.Belt_Type, is_flipped: bool, ref: AnimatedSprite2D) -> Belt:
	var inst = belt_scn.instantiate()
	inst.set_type(belt_type, rot, is_flipped, ref)
	inst.position = cell
	add_child(inst)
	inst.set_frame_and_progress(ref.get_frame(), ref.get_frame_progress())
	return inst
