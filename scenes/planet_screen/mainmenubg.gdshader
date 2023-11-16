shader_type canvas_item;

// Range (-0.5,0.5)
float rand(vec3 p) {
	return fract(sin(dot(p * 0.1 ,vec3(12.9898,78.233,6.8272))) * 43758.5453) - 0.5;
}

float cubic(float a, float b, float x) {
	return a + (b - a) * x * x * (3. - 2. * x);
}

// Range (-0.5,0.5)
float vnoise(vec3 p) {
	float result = 0.;
	vec3 i = floor(p);
	vec3 frac = fract(p);
	
	float a = rand(i);
	float b = rand(i + vec3(1., 0., 0.));
	float c = rand(i + vec3(0., 1., 0.));
	float d = rand(i + vec3(1., 1., 0.));
	float e = rand(i + vec3(0., 0., 1.));
	float f = rand(i + vec3(1., 0., 1.));
	float g = rand(i + vec3(0., 1., 1.));
	float h = rand(i + vec3(1., 1., 1.));
	
	float uf = cubic(a, b, frac.x);
	float df = cubic(c, d, frac.x);
	float ub = cubic(e, f, frac.x);
	float db = cubic(g, h, frac.x);
	
	float top = cubic(uf, ub, frac.z);
	float bottom = cubic(df, db, frac.z);
	
	result = cubic(top, bottom, frac.y);
	
	return result;
}

// Approximate range [-1,1]
float fnoise(vec3 p, int octs) {
	float result = 0.;
	
	for (int i = 0; i < octs; i++) {
		float multiplier = pow(0.5, float(i));
		result += multiplier * vnoise(p * pow(2., float(i + 2)));
	}
	
	return result * 0.75 + 0.5;
}

void fragment() {
	float val = floor(10. * clamp(fnoise(vec3(UV, TIME * 0.01), 4) - 0.5, 0., 1.)) * 0.1;
	COLOR = vec4(0.2 * val, 0.1 * val, 0.5 * val, 1.);
}
