extends KinematicBody2D


export var x_force: float 			= 50
export var jump_force: float 		= 1000
export var gravity : float 			= 75

var velocity: Vector2 = Vector2(0,0)
var force: Vector2 = Vector2(0, 0)
var max_velocity : Vector2 = Vector2(500, 10000000)
var max_force: Vector2 = Vector2(x_force, jump_force)

var distance_since_last_map_check: float = 0

onready var width: int = $Sprite.texture.get_width()
onready var height: int = $Sprite.texture.get_height()

onready var _map: TileMap = $"%TileMap"
onready var _max_distance_before_checking_map: float = _map.cell_size.x * _map.block_size


signal moved_block(direction)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Vector2(0, - height / 2)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_move_inputs()
	if Input.is_action_just_pressed("zoom_in"):
		$Camera2D.zoom *= .5
	elif Input.is_action_just_pressed("zoom_out"):
		$Camera2D.zoom *= 2 
#	print($Camera2D.zoom)
	
func _move() -> void:
	velocity.x = min(abs(velocity.x), max_velocity.x) * sign(velocity.x)
	velocity.y = min(abs(velocity.y), max_velocity.y) * sign(velocity.y)
	
	var old_pos: float = position.x
	velocity = move_and_slide(velocity)
	distance_since_last_map_check += (position.x - old_pos)
	
#	print(distance_since_last_map_check)
	if distance_since_last_map_check > _max_distance_before_checking_map:
		emit_signal("moved_block", 'east')
		distance_since_last_map_check = 0
	elif distance_since_last_map_check < - _max_distance_before_checking_map:
		emit_signal("moved_block", 'west')
		distance_since_last_map_check = 0


func _move_inputs() -> void:
	force = Vector2(0, gravity)
	
	if not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
		velocity.x = 0

	if Input.is_action_pressed("ui_right"):
		force.x += x_force
	elif Input.is_action_pressed("ui_left"):
		force.x -= x_force
			
#	elif Input.is_action_pressed("ui_down"):
#		force.y += x_force
#	elif Input.is_action_pressed("ui_up"):
#		force.y -= x_force
		
	if Input.is_action_just_pressed("ui_up"):
		force.y -= jump_force

	
	velocity += force
	_move()
	
	
		

func _get_tilemap_coordinates() -> Vector2:
	return get_parent().get_node('TileMap').world_to_map(position)
