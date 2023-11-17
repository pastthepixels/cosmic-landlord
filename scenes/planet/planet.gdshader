shader_type spatial;

instance uniform float water: hint_range(0.,1.);
instance uniform float oxygen: hint_range(0.,1.);
uniform sampler2D gradient: hint_default_black;

// discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3
vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

const float F3 =  0.3333333;
const float G3 =  0.1666667;
float snoise(vec3 p) {

	vec3 s = floor(p + dot(p, vec3(F3)));
	vec3 x = p - s + dot(s, vec3(G3));
	 
	vec3 e = step(vec3(0.0), x - x.yzx);
	vec3 i1 = e*(1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	vec3 x1 = x - i1 + G3;
	vec3 x2 = x - i2 + 2.0*G3;
	vec3 x3 = x - 1.0 + 3.0*G3;
	 
	vec4 w, d;
	 
	w.x = dot(x, x);
	w.y = dot(x1, x1);
	w.z = dot(x2, x2);
	w.w = dot(x3, x3);
	 
	w = max(0.6 - w, 0.0);
	 
	d.x = dot(random3(s), x);
	d.y = dot(random3(s + i1), x1);
	d.z = dot(random3(s + i2), x2);
	d.w = dot(random3(s + 1.0), x3);
	 
	w *= w;
	w *= w;
	d *= w;
	 
	return dot(d, vec4(52.0));
}

float fnoise(vec3 p, int octs) {
	float result = 0.;
	
	for (int i = 0; i < octs; i++) {
		float multiplier = pow(0.5, float(i));
		result += multiplier * snoise(p * pow(2., float(i)));
	}
	
	return result + 0.5;
}

void fragment() {
	float rotSpeed = 0.05;
	// Convert uv to cartesian coords
	float theta = 2. * PI * (UV.x + TIME * rotSpeed);
	float phi = PI * UV.y;
	vec3 samplePoint = vec3(cos(theta) * sin(phi), sin(theta) * sin(phi), -cos(phi));
	
	float groundVal = floor(10. * fnoise(samplePoint, 7) + 0.) * 0.1;
	float cloudVal = fnoise(samplePoint + 10. + TIME * 0.05, 4);
	
	vec4 finalColor = vec4(0.);
	
	finalColor = clamp(groundVal, 0.5, 1.) * texture(gradient, vec2(0.01 + oxygen * 0.98, 0.));
	
	if (groundVal < water) {
		float depth = 2. * (water - groundVal);
		finalColor = clamp(finalColor * (1. - depth) + vec4(0., 0., 0.1, 1.) * depth, 0., 1.);
	}
	
	if (cloudVal > 0.7) {
		finalColor = (vec4(1.) + 3. * finalColor) * 0.25;
	}
	
	ALBEDO = finalColor.rgb;
}
