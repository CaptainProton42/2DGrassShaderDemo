shader_type canvas_item;

uniform float wind_speed;
uniform vec2 wind_direction;
uniform vec4 tip_color : hint_color;
uniform vec4 wind_color : hint_color;
uniform sampler2D gradient;
uniform sampler2D tex;
uniform sampler2D noise_tex;
uniform vec2 noise_tex_size;
uniform sampler2D cloud_tex;

const float MAX_BLADE_LENGTH = 10.0f;
const float PI = 3.1415926535;

// Simple sine wave with period T, amplitude a, phase and direction
float sineWave(float T, float a, float phase, vec2 dir, vec2 pos) {
	return a * sin(2.0f * PI / T * dot(dir, pos) + phase);
}

vec4 sampleColor(float dist) {
	return texture(gradient, vec2(dist + 0.5f, 0.0f) / 3.0f);
}

float sampleBladeLength(vec2 uv) {
	return texture(tex, uv).r * 255.0f;
}

float sampleNoise(vec2 uv, vec2 texture_pixel_size, float offset) {
	return texture(noise_tex, vec2(uv.x / texture_pixel_size.x / noise_tex_size.x + offset, 0.0f)).r;
}

float wind (vec2 pos, float t) {
	return (sineWave(200.0f, 1.8f, 1.0f*wind_speed*t, normalize(wind_direction), pos)
		   + sineWave(70.0f, 0.1f, 2.0f*wind_speed*t, normalize(wind_direction - vec2(0.0f, 0.4f)), pos)
		   + sineWave(75.0f, 0.1f, 1.5f*wind_speed*t, normalize(wind_direction + vec2(0.4f, 0.0f)), pos))
		   / 3.0f;
}

void fragment() {
	// First, sample some 1D noise
	float noise = sampleNoise(UV, SCREEN_PIXEL_SIZE, 0.1f * wind_speed * TIME);
	// Add the nose to the uv for frayed grass
	vec2 uv = SCREEN_UV - vec2(0.0f, SCREEN_PIXEL_SIZE.y * noise);

	// Color the base of the grass with the first gradient color
	if (texture(tex, SCREEN_UV).r > 0.0f) {
		COLOR = sampleColor(0.0f);
		COLOR -= vec4(texture(cloud_tex, SCREEN_UV).rgb, 0.0f);
	} else {
		COLOR = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	}
	
	for (float dist = 0.0f; dist < MAX_BLADE_LENGTH; ++dist) {
		// Sample the wind
		float wind = wind(uv / SCREEN_PIXEL_SIZE, TIME);
		
		// Get the height of the balde originating at the current pixel
		// (0 means no blade)
		float blade_length = sampleBladeLength(uv);
		
		if (blade_length > 0.0f) {
			// Blades are pressed down by the wind
			if (wind > 0.5f) {
				blade_length -= 1.0f;
			}
			
			// Color basec on distance from root
			if (dist == blade_length) {
				// Color grass tips
				if (wind <= 0.5f) {
					COLOR = tip_color;
				} else {
					COLOR = wind_color;
				}
				
				// Add the cloud shadow
				COLOR -= vec4(texture(cloud_tex, uv).rgb, 0.0f);
			} else if (dist < blade_length) {
				// Color grass stems
				COLOR = sampleColor(dist);
				
				// Add the cloud shadow
				COLOR -= vec4(texture(cloud_tex, uv).rgb, 0.0f);
			}
		}
		
		// Move on to the next pixel, down the blades
		uv -= vec2(0.0f, SCREEN_PIXEL_SIZE.y);
	}
}