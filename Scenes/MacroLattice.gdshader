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
	return vel / 2. + .5;
}


float compute_density(vec2 uv){
	//Primary lattice contains the densities of the particles moving towards the 4 cardinal points N,E,S,W encoded as rgba values
	//Secondary lattice contains the densities of the particles moving towards for the 4 secondary cardinal points NE,SE,SW,NW encoded as rgba values
	//macro_lattice contains the total density and x, y velocities in channels z, x, y and the partial density of non moving particles in channel w.
	
	float density = 0.;
	
	density += texture(macro_lattice, uv).w;
	
	vec4 pri = texture(primary_dir_lattice, uv);
	vec4 sec = texture(secondary_dir_lattice, uv);
	
	density += pri.x;
	density += pri.y;
	density += pri.z;
	density += pri.w;
	
	density += sec.x;
	density += sec.y;
	density += sec.z;
	density += sec.w;
	
	return density;
}

vec2 compute_velocity(vec2 uv, float density){
	//Primary lattice contains the densities of the particles moving towards the 4 cardinal points N,E,S,W encoded as rgba values
	//Secondary lattice contains the densities of the particles moving towards for the 4 secondary cardinal points NE,SE,SW,NW encoded as rgba values
	//macro_lattice contains the total density and x, y velocities in channels z, x, y and the partial density of non moving particles in channel w.
	
	vec2 velocity = vec2(0., 0.);
	
	vec4 pri = texture(primary_dir_lattice, uv);
	vec4 sec = texture(secondary_dir_lattice, uv);
	
	velocity.x += pri.y;//E
	velocity.x -= pri.w;//W
	velocity.x += sec.x;//NE
	velocity.x += sec.y;//SE
	velocity.x -= sec.z;//SW
	velocity.x -= sec.w;//NW

	velocity.y += pri.x; //N
	velocity.y -= pri.z; //S
	velocity.y += sec.x; //NE
	velocity.y -= sec.y; //SE
	velocity.y -= sec.z; //SW
	velocity.y += sec.w; //NW
	
	velocity = vel_to_color(velocity / density);
	
	// Returns velocity vector as a color between 0 and 1!
	return velocity;
}

float eq_density(float density, vec2 velocity, float dir_weight){
	
	// Computes the equilibrium density for the partial densities. Here adapted to the non moving particles, which simplifies the equation.
	
//	float sound_speed = 100.; //sqrt(3. * k * temperature / mass);
	
	float n_eq = density * dir_weight;
//	float vel_dot = dot(direction, velocity);
	n_eq *= (1. - 1.5 * pow(length(velocity) / sound_speed, 2));
//	n_eq *= (1. + 3. * vel_dot / c + 4.5 * pow(vel_dot / c, 2) - 1.5 * pow(length(velocity) / c, 2));
	
	return n_eq;
}

void fragment(){
	if (texture(world, UV).a < 0.1){
		// Compute the macro density and velocity from the sum/average of each microscopic densities and velocities
		float density = compute_density(UV);
		vec2 velocity = compute_velocity(UV, density);
		
		COLOR.rg = velocity;
		COLOR.b = density;
		
		
		if(UV.x > 0.9){
			COLOR.w = 1.;
		}
		else{
//			float density  = compute_density(UV);
//			vec2 velocity = compute_velocity(UV, density);
//			COLOR.xyz = vec3(velocity, density);
			
			// Update the non moving particle density
			vec4 old_macro = texture(macro_lattice, UV);
			
			// Compute the density of thermal equilibrium for the non moving particles
			float n_eq = eq_density(old_macro.z, color_to_vel(old_macro.xy), 4./9.);
			
			COLOR.w = old_macro.w + equilibrium_factor * (n_eq - old_macro.w);
			
//			COLOR.w = 1.;
		}
	}
	
	else{
		COLOR = vec4(0., 0., 0., 0.)
	}
}






