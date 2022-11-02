shader_type canvas_item;

uniform sampler2D velocity;
uniform sampler2D world_texture;

void fragment()
{
	if (texture(world_texture, UV).a == 0.){
//		float x0 = texture(velocity, UV - vec2(1,0) * SCREEN_PIXEL_SIZE).x; //left pixel horizontal velocity
//		float x1 = texture(velocity, UV + vec2(1,0) * SCREEN_PIXEL_SIZE).x; //right pixel  horizontal velocity
//		float y0 = texture(velocity, UV - vec2(0,1) * SCREEN_PIXEL_SIZE).y; //top pixel vertical velocity
//		float y1 = texture(velocity, UV + vec2(0,1) * SCREEN_PIXEL_SIZE).y; //bottom pixel vertical velocity
//
//		float divergence = ((x1-x0) + (y1-y0)) * 0.5;
		
		float divergence;
		
		// Sample the fluid
		vec4 center = texture(velocity, UV) * 2.0 - 1.0;
		vec4 up 	= texture(velocity, UV + SCREEN_PIXEL_SIZE * vec2(0,1)) * 2.0 - 1.0;
		vec4 down 	= texture(velocity, UV - SCREEN_PIXEL_SIZE * vec2(0,1)) * 2.0 - 1.0;
		vec4 right 	= texture(velocity, UV + SCREEN_PIXEL_SIZE * vec2(1,0)) * 2.0 - 1.0;
		vec4 left 	= texture(velocity, UV - SCREEN_PIXEL_SIZE * vec2(1,0)) * 2.0 - 1.0;
		
		// Divergence step
		divergence = (right.x - left.x + up.y - down.y) * 0.5;
		COLOR.rgb = vec3(divergence) * 0.5 + 0.5;
	}
	else{
		COLOR.a = 0.;
	}
}