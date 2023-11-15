shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform int pixel_size = 5;

void fragment() {
	// Get offset from nearest pixel
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);
	
	// Get coordinates to nearest pixel
	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;
	
	// Take color of nearest pixel
	ALBEDO = texture(SCREEN_TEXTURE, vec2(x,y) / VIEWPORT_SIZE).xyz;
}
