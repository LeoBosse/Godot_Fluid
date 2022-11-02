shader_type particles;





float rand_from_seed(inout uint seed){
	int k;
	int s = int(seed);
	if(s == 0)
	s = 123415;
	k = s/ 1234;
	s = 3241 * (s - k * 1436) - 43523 * k;
	if (s < 0){
		s += 154136437;
	}
	seed = uint(s);
	return float(seed % uint(7354.)) / 7353.;
}

void vertex(){
	
	uint seed = NUMBER + RANDOM_SEED;
	
	if (RESTART){
//		Is only executed when the particle is spwned
		vec3 direction = vec3(rand_from_seed(seed) - 0.5, rand_from_seed(seed) - 0.5, 0.);
		float speed = rand_from_seed(seed) * 500.;
		VELOCITY = direction * speed;
	}
	else{
		VELOCITY.y += 2.0;
	}
	
	TRANSFORM[1].y = -1.;
	
//	if (TRANSFORM[3].x > 50.0){ 
//		If the x position if greater than 50pixels
//		VELOCITY = vec3(0); // Stop the particle
//		TRANSFORM[3].x = 0.;
//		RESTART = true;
//	}

	COLOR.a = max(COLOR.a - DELTA, 0.0);
}
