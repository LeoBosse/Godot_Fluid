shader_type canvas_item;

uniform float timestep;
uniform float dissipation;

uniform sampler2D velocity; //velocity - div(Pressure) texture
uniform sampler2D advected; //density texture
uniform sampler2D world_texture; // Object texture


// Computes the interpolation of the 4 adjacent pixels in the texture tex with a pixel size of tex_size, at position uv
vec4 bilinear_texture(sampler2D tex, vec2 uv, vec2 tex_size) 
{
    vec2 pos = uv / tex_size - 0.5; //position in pixels, ??-0.5 pixels??. 
	vec2 f = fract(pos); //Fractional
	vec2 i = floor(pos); //Floor (==vec 2 of int)

//	vec3 tl = texture(tex, (i + vec2(0.5, 0.5)) * tex_size).rgb;
//	vec3 tr = texture(tex, (i + vec2(1.5, 0.5)) * tex_size).rgb;
//	vec3 bl = texture(tex, (i + vec2(0.5, 1.5)) * tex_size).rgb;
//	vec3 br = texture(tex, (i + vec2(1.5, 1.5)) * tex_size).rgb;
	
	vec4 arr[4];
	int index = 0;
	for(float iu = 0.5; iu <= 1.5; iu++){
		for(float iv = 0.5; iv <= 1.5; iv++){
			vec2 corner_pos = (i + vec2(iu, iv)) * tex_size;
			if (texture(world_texture, corner_pos).a == 0.){
				arr[index] = vec4(texture(tex, corner_pos).rgb, 1.);
//				arr[index] = vec4(texture(world_texture, corner_pos).rgb, 1.);
			}
			else{
				arr[index] = vec4(0., 0., 0., 0.);
			}
			index += 1;
		}
	}
//	return mix( mix(tl, tr, f.x), mix(bl, br, f.x), f.y);
	
	return mix( mix(arr[0], arr[2], f.x), mix(arr[1], arr[3], f.x), f.y);
//	return texture(tex, uv);
}

vec2 color_to_vel(vec2 color){
	// Converts a 2d vector representing a color (in 0, 1 range) to a velocity (in -1, 1) range
	return color * 2. - 1.;
}

void fragment()
{
	if (texture(world_texture, UV).a == 0.){
		if (UV.x > 0.9){
			COLOR = vec4(.5, .5, .5, 1.);
		}
		else{
			vec2 p = UV - timestep * SCREEN_PIXEL_SIZE * color_to_vel(texture(velocity, UV).xy);
//			vec4 vel = texture(advected, p);
			vec4 vel = (bilinear_texture(advected, p, SCREEN_PIXEL_SIZE)) * dissipation;
		    COLOR.rgb = vec3(vel.rgb);
//			vec2 p = vec2(UV.x + 1000. * SCREEN_PIXEL_SIZE.x, UV.y);
//			COLOR = vec4(UV, 0., 1.);
//			COLOR = vec4(texture(advected, p).rgb, 1.);
		}
	}
	else{
		COLOR.a = 0.;
//		COLOR = vec4(0., 0., 0., 0.);
//		vec2 p = vec2(UV.x + 1000. * SCREEN_PIXEL_SIZE.x, UV.y);
//		COLOR = vec4(texture(advected, p).rgb, 1.);
	}
    
}