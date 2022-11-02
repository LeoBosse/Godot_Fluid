shader_type canvas_item;

uniform sampler2D pressure;
uniform sampler2D velocity;
uniform sampler2D world_texture;

void fragment()
{
	if (texture(world_texture, UV).a == 0.){
//		computes the pressure of neighbouring pixels between -1 and 1. Pressure is the Red channel.
		float x0 = (texture(pressure, UV - vec2(1,0) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
		float x1 = (texture(pressure, UV + vec2(1,0) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
		float y0 = (texture(pressure, UV - vec2(0,1) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
		float y1 = (texture(pressure, UV + vec2(0,1) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
		
//		Computes the pressure gradient. (dPx / dx, dPy / dy) = ((x1-x0) / 2, (y1, y0)/2) in the interval [-1, 1].
		vec2 pressure_gradient = (vec2(x1, y1) - vec2(x0, y0)) * 0.5; 
		vec2 old_velocity = texture(velocity, UV).xy * 2. - 1.; // in the intervalle [-1, 1]
		
		COLOR.rgb = vec3((old_velocity - pressure_gradient) / 2. + 0.5, 0.5);
	}
	else{
		COLOR.a = 0.;
	}
}