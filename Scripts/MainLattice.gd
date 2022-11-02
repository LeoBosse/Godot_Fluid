extends Node2D


onready var screen_size: Vector2 = get_viewport().get_size()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("World/WorldViewport").size = screen_size;
	get_node("World").rect_size = screen_size;
	
	get_node("Air/AirTexture/PrimaryDirViewport").size = screen_size;
	get_node("Air/AirTexture/SecondaryDirViewport").size = screen_size;
	get_node("Air/AirTexture/MacroViewport").size = screen_size;
	get_node("Air/AirTexture/PrimaryDirViewport2").size = screen_size;
	get_node("Air/AirTexture/SecondaryDirViewport2").size = screen_size;
	get_node("Air/AirTexture/MacroViewport2").size = screen_size;
	get_node("Air/AirTexture").rect_size = screen_size;
	get_node("Air").rect_size = screen_size;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
