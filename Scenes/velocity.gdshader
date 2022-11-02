shader_type canvas_item;

uniform float timestep;
uniform float dissipation;

uniform sampler2D velocity;
uniform sampler2D world_texture;


vec2 bilinear_texture(sampler2D tex, vec2 uv, vec2 tex_size) 
{
    vec2 pos = uv / tex_size - 0.5;
	vec2 f = fract(pos);
	vec2 i = floor(pos);

//	vec3 tl = texture(tex, (i + vec2(0.5, 0.5)) * tex_size).rgb;
//	vec3 tr = texture(tex, (i + vec2(1.5, 0.5)) * tex_size).rgb;
//	vec3 bl = texture(tex, (i + vec2(0.5, 1.5)) * tex_size).rgb;
//	vec3 br = texture(tex, (i + vec2(1.5, 1.5)) * tex_size).rgb;
	
	vec2 arr[4];
	int index = 0;
	for(float iu = 0.5; iu <= 1.5; iu++){
		for(float iv = 0.5; iv <= 1.5; iv++){
			vec2 corner_pos = (i + vec2(iu, iv)) * tex_size;
			if (texture(world_texture, corner_pos).a == 0.){
				arr[index] = texture(tex, corner_pos).xy;
//				arr[index] = vec2(1, 0.);
			}
			else{
				arr[index] = vec2(0.5, 0.5);
			}
			index += 1;
		}
	}
//	return mix( mix(tl, tr, f.x), mix(bl, br, f.x), f.y);
	return mix( mix(arr[0], arr[2], f.x), mix(arr[1], arr[3], f.x), f.y);
}

vec2 color_to_vel(vec2 color){
	// Converts a 2d vector representing a color (in 0, 1 range) to a velocity (in -1, 1) range
	return color * 2. - 1.;
}
vec2 vel_to_color(vec2 vel){
	// Converts a 2d vector representing a velocity (in -1, 1 range) to a color (in 0, 1) range
	return vel / 2. + 0.5;
}

void fragment()
{
	if (texture(world_texture, UV).a == 0.){
		if (UV.x > 0.9){
			COLOR = vec4(vel_to_color(vec2(-0.5, 0.)), 0.5, 1.);
		}
		else{
			vec2 p = UV - timestep * SCREEN_PIXEL_SIZE * color_to_vel(texture(velocity, UV).xy);
			vec2 vel = color_to_vel(bilinear_texture(velocity, p, SCREEN_PIXEL_SIZE)) * dissipation;
    		COLOR = vec4(vel_to_color(vel), .5, 1.);
		}
//		COLOR.rgb = vec3(UV, 0.);
	}
	else{
		COLOR.a = 0.;
	}
    
}