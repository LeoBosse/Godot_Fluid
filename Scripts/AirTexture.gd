extends TextureRect

# For this lattice algorithm, look at https://physics.weber.edu/schroeder/javacourse/LatticeBoltzmann.pdf

var path: String = "Air/AirTexture/"
var viewports: Array = ["./Debug", "./Density", "./VeclocityX", "./VeclocityY", "./PrimaryDirViewport", "./SecondaryDirViewport", "./MacroViewport", "./PrimaryDirViewport2", "./SecondaryDirViewport2", "./MacroViewport2"]
var viewport_index: int = 0;

onready var primary = $"%PrimaryTexture".material
onready var secondary = $"%SecondaryTexture".material
onready var macro = $"%MacroTexture".material

onready var primary2 = $"%PrimaryTexture2".material
onready var secondary2 = $"%SecondaryTexture2".material
onready var macro2 = $"%MacroTexture2".material

#export(float) var timestep = 1.0;
#export(float) var velocity_dissipation = 1.0
#export(float) var density_dissipation = 1.0

export(float) var cst_boltzmann = 1 #1.38 * pow(10, -23)
export(float) var temperature = 1 #300
export(float) var mass = 1 #pow(10, -21)

export(float) var equilibrium_factor = 0.5
export(float) var sound_speed = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	primary.set_shader_param("cst_boltzmann", cst_boltzmann)
	secondary.set_shader_param("cst_boltzmann", cst_boltzmann)
	macro.set_shader_param("cst_boltzmann", cst_boltzmann)
	primary.set_shader_param("temperature", temperature)
	secondary.set_shader_param("temperature", temperature)
	macro.set_shader_param("temperature", temperature)
	primary.set_shader_param("mass", mass)
	secondary.set_shader_param("mass", mass)
	macro.set_shader_param("mass", mass)
	primary2.set_shader_param("cst_boltzmann", cst_boltzmann)
	secondary2.set_shader_param("cst_boltzmann", cst_boltzmann)
	macro2.set_shader_param("cst_boltzmann", cst_boltzmann)
	primary2.set_shader_param("temperature", temperature)
	secondary2.set_shader_param("temperature", temperature)
	macro2.set_shader_param("temperature", temperature)
	primary2.set_shader_param("mass", mass)
	secondary2.set_shader_param("mass", mass)
	macro2.set_shader_param("mass", mass)
	macro.set_shader_param("equilibrium_factor", equilibrium_factor)
	macro2.set_shader_param("equilibrium_factor", equilibrium_factor)
	primary.set_shader_param("equilibrium_factor", equilibrium_factor)
	primary2.set_shader_param("equilibrium_factor", equilibrium_factor)
	secondary.set_shader_param("equilibrium_factor", equilibrium_factor)
	secondary2.set_shader_param("equilibrium_factor", equilibrium_factor)
	macro.set_shader_param("sound_speed", sound_speed)
	macro2.set_shader_param("sound_speed", sound_speed)
	primary.set_shader_param("sound_speed", sound_speed)
	primary2.set_shader_param("sound_speed", sound_speed)
	secondary.set_shader_param("sound_speed", sound_speed)
	secondary2.set_shader_param("sound_speed", sound_speed)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_viewports()


func change_viewports():
	if Input.is_action_just_pressed("cycle_viewports"):
		viewport_index = (viewport_index + 1) % viewports.size()
	texture.viewport_path = path + viewports[viewport_index]
	get_node("../ViewportLabel").text = viewports[viewport_index]
