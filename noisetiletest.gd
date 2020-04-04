extends Node2D

var scl = 4
var size = 16
const TILE_SCENE = preload("res://test/Tile.tscn")
onready var player = get_node("../../player")
var world_size = Vector2(8, 4) # use 20, 12
var terrain = {}
var tiles = []
var current_pos

var noise = OpenSimplexNoise.new()

func getTerrain(x):
	if x < 0.1:
		return terrain[OCEAN]
	elif x < 0.3:
		return terrain[WATER]
	elif x < 0.4:
		return terrain[SAND]
	elif x < 0.85:
		return terrain[GRASS]
	else:
		return terrain[FOREST]

func _ready():
	init_terrain()
	noise.seed = randi()
	noise.lacunarity = 2.0 # difference in period between octaves
	noise.octaves = 4 # number of passes (noise layers) sampled to get fractal noise (Max 9)
	noise.period = 18.0 # lower period = higher-frequency noise (more change across same distance)
	noise.persistence = 0.4 # contribution factor of subsequent octaves
	for i in range(-world_size.x, world_size.x+1):
		var current_column = []
		for j in range(-world_size.y, world_size.y+1):
			current_column.append(createTile(i, j))
		tiles.append(current_column)
	current_pos = Vector2(int(player.get_position().x)/size, int(player.get_position().y)/size)

func _process(_delta):
	var pos = Vector2(int(player.get_position().x)/size, int(player.get_position().y)/size)
	if pos.x > current_pos.x: # Moving right
		current_pos.x = pos.x
		
		for t in tiles.pop_front():
			t.queue_free()
			
		var new_tiles = []
		var new_x = tiles.back()[0].position.x/size + 1
		for j in range(tiles[0].front().position.y/size, tiles[0].back().position.y/size + 1):
			new_tiles.append(createTile(new_x, j))
			
		tiles.append(new_tiles)
	if pos.x < current_pos.x: # Moving left
		current_pos.x = pos.x
		
		for t in tiles.pop_back():
			t.queue_free()
			
		var new_tiles = []
		var new_x = tiles.front()[0].position.x/size - 1
		for j in range(tiles[0].front().position.y/size, tiles[0].back().position.y/size + 1):
			new_tiles.append(createTile(new_x, j))
			
		tiles.push_front(new_tiles)
	if pos.y > current_pos.y: # Moving down
		current_pos.y = pos.y
		
		for c in tiles:
			c.pop_front().queue_free()
			
		var new_tiles = []
		var new_y = tiles[0].back().position.y/size + 1
		for i in range(tiles.front()[0].position.x/size, tiles.back()[0].position.x/size + 1):
			new_tiles.append(createTile(i, new_y))
			
		for j in range(new_tiles.size()):
			tiles[j].push_back(new_tiles[j])
	if pos.y < current_pos.y: # Moving up
		current_pos.y = pos.y
		
		for c in tiles:
			c.pop_back().queue_free()
			
		var new_tiles = []
		var new_y = tiles[0].front().position.y/size - 1
		for i in range(tiles.front()[0].position.x/size, tiles.back()[0].position.x/size + 1):
			new_tiles.append(createTile(i, new_y))
			
		for j in range(new_tiles.size()):
			tiles[j].push_front(new_tiles[j])

func createTile(x, y):
	var noise_value = noise.get_noise_2d(x*scl, y*scl)
	var remapped_noise_value = remap_range(noise_value, -1.0, 1.0, 0.0, 1.0)
	var t = TILE_SCENE.instance()
	add_child(t)
	t.set_position(Vector2(x * size, y * size))
	t.set_color(getTerrain(remapped_noise_value))
	return t

func remap_range(input, minInput, maxInput, minOutput, maxOutput):
	return(input - minInput) / (maxInput - minInput) * (maxOutput - minOutput) + minOutput

enum {GRASS, FOREST, SAND, WATER, OCEAN}

func init_terrain():
	terrain[GRASS] = Color(60.0/255, 181.0/255, 33.0/255)
	terrain[FOREST] = Color(13.0/255, 110.0/255, 26.0/255)
	terrain[SAND] = Color(173.0/255, 132.0/255, 19.0/255)
	terrain[WATER] = Color(27.0/255, 112.0/255, 209.0/255)
	terrain[OCEAN] = Color(10.0/255, 58.0/255, 112.0/255)
	
