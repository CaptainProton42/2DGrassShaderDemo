shader_type canvas_item;

uniform sampler2D grass_tex;
uniform sampler2D noise_tex;
uniform vec2 noise_tex_size;
uniform float wind_speed;

const float MAX_BLADE_LENGTH = 10.0f;

float sampleNoise(vec2 uv, vec2 texture_pixel_size, float offset) {
	return texture(noise_tex, vec2(uv.x / texture_pixel_size.x / noise_tex_size.x + offset, 0.0f)).r;
}

void fragment() {
	// First, color the sprite normally
	COLOR = texture(TEXTURE, UV);
	
	// Sample some noise
	float noise = sampleNoise(SCREEN_UV, SCREEN_PIXEL_SIZE, 0.1f*TIME);
	
	// Determine how "high" we are in pixels
	float height = (1.0f - UV.y) / TEXTURE_PIXEL_SIZE.y;
	
	// Determine screen uv at the bottom of the sprite
	vec2 uv = SCREEN_UV - vec2(0.0f, height * SCREEN_PIXEL_SIZE.y);
	
	// We need to look for blades below the sprite until we reach the max blade length
	for (float i = 0.0f; i < MAX_BLADE_LENGTH; ++i) {
		// Sample the blade length
		float blade_length = texture(grass_tex, uv).r * 255.0f;
		blade_length += noise; // and add some noise
		
		// The current pixel is below the blade tip, do not draw it
		if (height <= blade_length) {
			COLOR=vec4(0.0f, 0.0f, 0.0f, 0.0f);
		}
		
		// Move down to the next pixel
		uv.y -= SCREEN_PIXEL_SIZE.y;
		height += 1.0f;
	}
}