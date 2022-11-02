shader_type canvas_item;

uniform float cst_boltzmann;
uniform float temperature;
uniform sampler2D divergence; // velocity divergence
uniform sampler2D density;
uniform sampler2D pressure; // pressure
uniform sampler2D world_texture;

float sample_pressure(sampler2D tex, vec2 pos, float default_p)
{
	vec2 p = texture(tex, pos).rg;
	
	return mix(p.r * 2.0 - 1.0, default_p, p.g);
}

void fragment()
{
	if (texture(world_texture, UV).a == 0.){
//		if (UV.x > 0.9){
//			COLOR.rgb = vec3(1., 1., 1.);
//		}
//		else{
			float l = (texture(pressure, UV - vec2(1,0) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
			float r = (texture(pressure, UV + vec2(1,0) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
			float b = (texture(pressure, UV - vec2(0,1) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
			float t = (texture(pressure, UV + vec2(0,1) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
//			float l = (texture(SCREEN_TEXTURE, SCREEN_UV - vec2(1,0) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
//			float r = (texture(SCREEN_TEXTURE, SCREEN_UV + vec2(1,0) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
//			float b = (texture(SCREEN_TEXTURE, SCREEN_UV - vec2(0,1) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
//			float t = (texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0,1) * SCREEN_PIXEL_SIZE).r * 2.0 - 1.0);
//
			float c = (texture(divergence, UV).x * 2.0 - 1.0) ;

			COLOR.rgb = vec3((l+r+b+t - c) * 0.25) * 0.5 + 0.5;
//
//			COLOR.rgb = texture(density, UV).rgb / (SCREEN_PIXEL_SIZE.x * SCREEN_PIXEL_SIZE.y) * cst_boltzmann * temperature;
			
	//		COLOR.rgb = vec3(UV, 0.)
//		}
	}
	else{
		COLOR.a = 0.;
	}
}