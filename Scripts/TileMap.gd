extends TileMap

enum{	iWEST = 0,
		iEAST = 1,
		WEST = -1,
		EAST =  1}

var dir_index := {"east": iEAST, "west": iWEST}
var dir_sign := {"east": EAST, "west": WEST}

var depth: int = 0

var horizon_tiles: = [0, 0]
var horizon_block := [0, 0]

var block_size: int = 10 #Must be even
var max_nb_blocks: int = 10
var nb_blocks: int = 0

var vertical_boundaries: Array = [-15, 10]

onready var noise := OpenSimplexNoise.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(block_size % 2 == 0, "Block size is not even. This will mess up the tile to block rescaling.")
	
	# Configure
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	_set_first_block()
	for i in max_nb_blocks/2:
		_append_block('east')
		
	_add_wall(Vector2(0, (vertical_boundaries[0] - 10) * cell_size.y), Vector2(cell_size.x * 1000, 10 * cell_size.y))
	
	
func _add_wall(position:Vector2, size:Vector2) -> void:
	var rect:= RectangleShape2D.new()
	rect.set_extents(size) #Vector2(cell_size.x * 1000, 1))
	var collision_shape: = CollisionShape2D.new()
	collision_shape.shape = rect
	var collision_object := StaticBody2D.new()
	collision_object.position = position #Vector2(0, vertical_boundaries[0]) 
	collision_object.add_child(collision_shape)
	
#	collision_object.collision_layer = 0
#	collision_object.set_collision_layer_bit(CollisionLayers.Layers.WALL, true)
#	collision_object.collision_mask = 0

	add_child(collision_object)
	

func _on_Player_moved_block(direction) -> void:
#	print('COUCOU')
	_append_block(direction)
	if nb_blocks > max_nb_blocks:
		_delete_block(_get_opposite(direction))


func _get_opposite(dir:String) -> String:
	if dir == 'east':
		return 'west'
	else:
		return 'east'
	
func _get_block_tile_borders(block:int) -> Array:
	var west_tile: int = block_size * (block)
	var east_tile: int = block_size * (block + 1) - 1
	return [west_tile, east_tile]
	

func get_pixel_altitude(x_pixel_pos:int) -> float:
	var x_pos: int = world_to_map(Vector2(x_pixel_pos, 0)).x
	return map_to_world(Vector2(0, get_altitude(x_pos))).y
	
func get_altitude(x_cell:int) -> int:
	return int(noise.get_noise_2d(x_cell, depth) * 10)

func _set_first_block() -> void:
	nb_blocks += 1
	horizon_block[iWEST] = 0
	var x: int = - block_size
	for i in block_size * 2:
#		set_cell(- block_size + 1, -i, 1)
		for j in range(0, vertical_boundaries[1]):
			set_cell(x, j, 1)
		x += 1
	set_cell(10, -5, 1)
	update_bitmask_region(Vector2(- block_size, vertical_boundaries[0]), Vector2(x - 1, vertical_boundaries[1]));
	
func _delete_first_block() -> void:
	nb_blocks -= 1
	horizon_block[iWEST] = 1
	var x: int = - block_size
	for i in block_size * 2:
		for j in range(vertical_boundaries[0], vertical_boundaries[1]):
			set_cell(x, j, -1)
		x += 1
	
	
func _append_block(dir:String) -> bool:
	# If the maximum of block is already reached, do not create another
	if nb_blocks > max_nb_blocks:
		return false
	
	var dir_i: int = dir_index[dir] #Get the direction index from a string
	var inc_sign: int = dir_sign[dir]
	var previous_block: int = horizon_block[dir_i] # Get the id number of the previous block
	var added_block: int = previous_block + inc_sign
	
	if added_block == 0:
		_set_first_block()
		return true
	elif added_block < 0:
		return false
	
	var added_block_borders: Array = _get_block_tile_borders(added_block)
	
	nb_blocks += 1
	horizon_block[dir_i] = added_block
	
	var x: int = added_block_borders[(dir_i+1)%2]
	var alt: int = get_altitude(x) #int(noise.get_noise_2d(x, depth) * 10)
	for i in block_size:
		for j in range(alt, vertical_boundaries[1]):
			set_cell(x, j, 1)
		x += inc_sign
		alt = get_altitude(x) #int(noise.get_noise_2d(x, depth) * 10)
		
	update_bitmask_region(Vector2(added_block_borders[0], vertical_boundaries[0]), Vector2(added_block_borders[1], vertical_boundaries[1]));
	update_dirty_quadrants()
	
	return true


func _delete_block(dir:String) -> void:
	var dir_i: int = dir_index[dir] #Get the direction index from a string
	var inc_sign: int = dir_sign[dir]
	var del_block: int = horizon_block[dir_i] # Get the id number of the block to delete
	
	if del_block == 0:
		_delete_first_block()
	
	var del_block_borders: Array = _get_block_tile_borders(del_block)
	
	nb_blocks -= 1
	horizon_block[dir_i] = del_block - inc_sign
	
	var x: int = del_block_borders[dir_i]
	var alt: int = get_altitude(x) #int(noise.get_noise_2d(x, depth) * 10)
	for i in block_size:
		var j: int = vertical_boundaries[1]
		while j >= alt: #get_cell(x, j) != -1:
			set_cell(x, j, -1)
			j -= 1
		x -= inc_sign
		alt = get_altitude(x) #int(noise.get_noise_2d(x, depth) * 10)
	
#	update_dirty_quadrants()
#		
