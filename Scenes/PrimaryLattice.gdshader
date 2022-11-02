shader_type canvas_item;

uniform float temperature;
uniform float mass;
uniform float k;
uniform float sound_speed;

uniform float equilibrium_factor;

uniform sampler2D primary_dir_lattice;
uniform sampler2D secondary_dir_lattice;
uniform sampler2D macro_lattice;

uniform sampler2D world;


vec2 color_to_vel(vec2 color){
	return color * 2. - 1.;
}

vec2 vel_to_color(vec2 vel){
	return vel / 2. + 0.5;
}

float eq_density(float density, vec2 velocity, float dir_weight, vec2 direction){
	
	// Computes the equilibrium density for the partial densities.

//	float sound_speed = 100.; //sqrt(3. * k * temperature / mass);
	
	float n_eq = density * dir_weight;
	float vel_dot = direction.x * velocity.x + direction.y * velocity.y;
	float vel_norm = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2));
	n_eq *= (1. + 3. * vel_dot / sound_speed + 4.5 * pow(vel_dot / sound_speed, 2) - 1.5 * pow(vel_norm / sound_speed, 2));
	
	return n_eq;
}

vec4 get_next_density(vec2 uv, vec2 direction, sampler2D past_density, sampler2D macro_param, vec2 pix_size){
	
	vec2 old_pos = uv - direction * pix_size;
	vec3 macro = texture(macro_param, old_pos).xyz;
	float n_eq = eq_density(macro.z, color_to_vel(macro.xy), 1./9., direction);
	vec4 old_density = texture(past_density, old_pos);
	return old_density + equilibrium_factor * (n_eq - old_density);
	 
}

void fragment(){
	if (texture(world, UV).a < 0.1){
		if (UV.x > 0.9){
			COLOR = vec4(0.5, 0.5, 0.5, 1.); // N E S W
		}
		else{
			// north
			COLOR.x = get_next_density(UV, vec2(0., 1.), primary_dir_lattice, macro_lattice, SCREEN_PIXEL_SIZE).x;
			// east
			COLOR.y = get_next_density(UV, vec2(1., 0.), primary_dir_lattice, macro_lattice, SCREEN_PIXEL_SIZE).y;
			// south
			COLOR.z = get_next_density(UV, vec2(0., -1.), primary_dir_lattice, macro_lattice, SCREEN_PIXEL_SIZE).z;
			// west
			COLOR.w = get_next_density(UV, vec2(-1., 0.), primary_dir_lattice, macro_lattice, SCREEN_PIXEL_SIZE).w;
			
//			COLOR = vec4(UV, 0., 1.);
		}
	}
	else{
		COLOR = vec4(0., 0., 0., 0.)
	}
}




















