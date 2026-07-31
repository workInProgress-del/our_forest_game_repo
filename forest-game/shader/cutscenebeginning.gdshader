shader_type canvas_item;
render_mode unshaded;

/*
	============================================================================
	SPOOKY VHS SECURITY CAMERA MONITOR SHADER
	============================================================================
	For Godot 4.3+ (CanvasItem / full-screen post-process)
	
	This shader simulates a haunted/malfunctioning VHS security camera monitor.
	Perfect for horror games, found-footage scenes, or creepy surveillance rooms.
	
	Features:
	- CRT barrel distortion with rounded corners
	- Heavy chromatic aberration (RGB split)
	- Scanlines + interlacing flicker
	- VHS tape wobble, jitter, and tracking errors
	- Rolling tracking bars
	- Tape grain, noise, and white specks
	- Occasional frame drops / signal loss
	- Spooky green night-vision tint option
	- Vignette + screen glow
	- Random "ghost" flickers and brightness pulses
	
	Layering Note:
	This shader uses hint_screen_texture + SCREEN_UV, so it only affects
	whatever is drawn BEHIND this ColorRect.
	
	For clean UI/HUD:
	- Put this shader on CanvasLayer 0
	- Put your UI on CanvasLayer 1 (or higher)
	============================================================================
*/

// The screen texture we read from (already rendered frame behind this rect)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// ============================================================================
// COLOR & TONE CONTROLS
// ============================================================================

// Overall brightness of the image
uniform float brightness : hint_range(0.0, 3.0) = 1.0;

// Contrast adjustment (1.0 = normal)
uniform float contrast : hint_range(0.0, 3.0) = 1.15;

// Saturation (0.0 = grayscale, 1.0 = normal, >1.0 = oversaturated)
uniform float saturation : hint_range(0.0, 2.0) = 0.65;

// Gamma correction
uniform float gamma : hint_range(0.2, 3.0) = 1.2;

// ============================================================================
// SPOOKY TINT OPTIONS
// ============================================================================

// Enable spooky green night-vision tint (0 = off, 1 = full)
uniform float night_vision_tint : hint_range(0.0, 1.0) = 0.35;

// Enable sickly yellow/brown decay tint (0 = off, 1 = full)
uniform float decay_tint : hint_range(0.0, 1.0) = 0.0;

// Overall color temperature shift (-1 = cold blue, 1 = warm orange)
uniform float color_temp : hint_range(-1.0, 1.0) = -0.15;

// ============================================================================
// CRT GEOMETRY
// ============================================================================

// How much the screen bulges outward (barrel distortion)
uniform float curvature : hint_range(0.0, 0.5) = 0.12;

// How soft the rounded screen corners are
uniform float corner_soften : hint_range(0.0, 0.3) = 0.08;

// Vignette darkness at the edges (0 = none, 1 = very dark)
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.5;

// ============================================================================
// SCANLINES
// ============================================================================

// How dark the scanlines are (0 = invisible, 1 = very dark)
uniform float scanline_strength : hint_range(0.0, 2.0) = 0.85;

// How many scanlines per screen height
uniform float scanline_density : hint_range(0.5, 4.0) = 1.2;

// Interlacing flicker effect strength
uniform float interlace_strength : hint_range(0.0, 1.0) = 0.3;

// ============================================================================
// VHS / TAPE ARTIFACTS
// ============================================================================

// Horizontal chromatic aberration (RGB channel split in pixels)
uniform float chroma_shift_px : hint_range(0.0, 10.0) = 2.5;

// Vertical chromatic aberration (extra spooky)
uniform float chroma_shift_y_px : hint_range(0.0, 5.0) = 0.5;

// Horizontal smear / ghosting (pixels)
uniform float luma_smear_px : hint_range(0.0, 10.0) = 3.0;

// Per-line horizontal jitter (random twitch per scanline)
uniform float jitter_px : hint_range(0.0, 8.0) = 2.0;

// Slow sine-wave wobble across the screen
uniform float wobble_px : hint_range(0.0, 12.0) = 2.5;

// How fast the wobble moves
uniform float wobble_speed : hint_range(0.0, 5.0) = 1.0;

// ============================================================================
// NOISE & GRAIN
// ============================================================================

// General tape grain intensity
uniform float tape_noise : hint_range(0.0, 1.0) = 0.3;

// Random horizontal tracking lines
uniform float tracking_lines : hint_range(0.0, 1.0) = 0.4;

// White speck intensity (dead pixels / tape damage)
uniform float white_specks : hint_range(0.0, 1.0) = 0.15;

// ============================================================================
// ROLLING BAR
// ============================================================================

// Speed of the rolling tracking bar
uniform float roll_speed : hint_range(0.0, 2.0) = 0.08;

// Brightness of the rolling bar
uniform float roll_strength : hint_range(0.0, 0.8) = 0.2;

// ============================================================================
// SPOOKY FLICKERS
// ============================================================================

// Random brightness flicker intensity
uniform float flicker_strength : hint_range(0.0, 1.0) = 0.15;

// How often flickers happen (higher = more frequent)
uniform float flicker_frequency : hint_range(0.0, 10.0) = 2.0;

// Random signal dropout (screen goes to static)
uniform float dropout_chance : hint_range(0.0, 1.0) = 0.02;

// How long dropouts last
uniform float dropout_duration : hint_range(0.0, 1.0) = 0.3;

// ============================================================================
// GLOW & BLOOM
// ============================================================================

// Glow strength on bright areas
uniform float glow_strength : hint_range(0.0, 2.0) = 0.3;

// Brightness threshold for glow
uniform float glow_threshold : hint_range(0.0, 1.0) = 0.6;

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

// Simple 1D hash function for pseudo-random numbers
float hash11(float n) {
	return fract(sin(n) * 43758.5453123);
}

// 2D hash function for noise
float hash12(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Smooth noise function for more organic randomness
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f); // Smoothstep interpolation
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Apply CRT barrel distortion to UV coordinates
vec2 crt_curve(vec2 uv, float k) {
	// Convert UV to centered coordinates (-1 to 1)
	vec2 cc = uv * 2.0 - 1.0;
	// Calculate distance squared from center
	vec2 d = cc * cc;
	// Apply barrel distortion
	cc *= 1.0 + k * vec2(d.y, d.x);
	// Convert back to 0-1 range
	return cc * 0.5 + 0.5;
}

// Check if UV is inside the 0-1 screen bounds
float inside01(vec2 uv) {
	return step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
}

// Apply brightness, contrast, saturation, and gamma
vec3 apply_color_controls(vec3 color) {
	// Brightness
	color *= brightness;
	
	// Contrast (centered around 0.5)
	color = mix(vec3(0.5), color, contrast);
	
	// Saturation
	float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
	color = mix(vec3(luma), color, saturation);
	
	// Gamma
	color = pow(max(color, vec3(0.0)), vec3(1.0 / max(gamma, 0.0001)));
	
	return color;
}

// Sample the screen texture at given UV
vec3 sample_screen(vec2 uv) {
	return textureLod(screen_texture, uv, 0.0).rgb;
}

// ============================================================================
// MAIN FRAGMENT FUNCTION
// ============================================================================

void fragment() {
	// Get screen pixel size and resolution
	vec2 px = SCREEN_PIXEL_SIZE;
	vec2 res = 1.0 / px;
	
	// Current time
	float t = TIME;
	
	// Start with screen UV coordinates
	vec2 uv = SCREEN_UV;
	
	// ------------------------------------------------------------------------
	// SPOOKY FLICKER EFFECT
	// Random brightness pulses that make the image feel unstable
	// ------------------------------------------------------------------------
	float flicker_time = floor(t * flicker_frequency * 10.0);
	float flicker_random = hash11(flicker_time);
	float flicker = 1.0 - flicker_strength * step(0.85, flicker_random) * 
	                  smoothstep(0.0, 0.1, fract(t * flicker_frequency));
	
	// ------------------------------------------------------------------------
	// SIGNAL DROPOUT (random static bursts)
	// Simulates the tape losing signal briefly
	// ------------------------------------------------------------------------
	float dropout_time = floor(t * 3.0);
	float dropout_random = hash11(dropout_time * 73.0);
	float dropout = step(1.0 - dropout_chance, dropout_random);
	float dropout_fade = smoothstep(0.0, dropout_duration, fract(t * 3.0));
	float dropout_active = dropout * (1.0 - dropout_fade);
	
	// ------------------------------------------------------------------------
	// VHS LINE JITTER
	// Each scanline gets a random horizontal offset
	// ------------------------------------------------------------------------
	float y_line = floor(uv.y * res.y);
	float jitter_seed = y_line + floor(t * 12.0) * 37.0;
	float jitter_random = hash11(jitter_seed);
	float jitter = (jitter_random - 0.5) * 2.0;
	uv.x += jitter * jitter_px * px.x;
	
	// ------------------------------------------------------------------------
	// SLOW WOBBLE
	// A sine wave that slowly distorts the image horizontally
	// ------------------------------------------------------------------------
	float wobble = sin(uv.y * 6.0 + t * wobble_speed) * wobble_px * px.x;
	uv.x += wobble;
	
	// ------------------------------------------------------------------------
	// CRT BARREL DISTORTION
	// ------------------------------------------------------------------------
	vec2 cuv = crt_curve(uv, curvature);
	float in_bounds = inside01(cuv);
	
	// ------------------------------------------------------------------------
	// ROUNDED CORNERS / SOFT SCREEN EDGE
	// ------------------------------------------------------------------------
	vec2 corner_distance = abs(cuv - 0.5) * 2.0;
	float edge = max(corner_distance.x, corner_distance.y);
	float corner_mask = 1.0 - smoothstep(1.0 - corner_soften, 1.0, edge);
	
	// ------------------------------------------------------------------------
	// CHROMATIC ABERRATION (RGB SPLIT)
	// Red and blue channels are offset horizontally and vertically
	// This is the classic "ghostly" VHS look
	// ------------------------------------------------------------------------
	vec2 chroma_offset_x = vec2(chroma_shift_px * px.x, 0.0);
	vec2 chroma_offset_y = vec2(0.0, chroma_shift_y_px * px.y);
	
	float red   = sample_screen(cuv + chroma_offset_x + chroma_offset_y).r;
	float green = sample_screen(cuv).g;
	float blue  = sample_screen(cuv - chroma_offset_x - chroma_offset_y).b;
	
	vec3 color = vec3(red, green, blue);
	
	// ------------------------------------------------------------------------
	// LUMA SMEAR / HORIZONTAL GHOSTING
	// Bright pixels leave trails behind them
	// ------------------------------------------------------------------------
	float smear = luma_smear_px * px.x;
	vec3 smear_right = sample_screen(cuv + vec2(smear, 0.0));
	vec3 smear_left  = sample_screen(cuv - vec2(smear, 0.0));
	vec3 smeared = (color + smear_right + smear_left) / 3.0;
	color = mix(color, smeared, 0.4);
	
	// ------------------------------------------------------------------------
	// SCANLINES
	// Dark horizontal lines across the screen
	// ------------------------------------------------------------------------
	float scanline_wave = sin(cuv.y * res.y * 3.14159 * scanline_density);
	float scanline_darkening = 0.5 - 0.5 * scanline_wave;
	float scanline_mult = 1.0 - scanline_strength * scanline_darkening;
	color *= scanline_mult;
	
	// ------------------------------------------------------------------------
	// INTERLACING FLICKER
	// Every other line flickers slightly, simulating old CRT interlacing
	// ------------------------------------------------------------------------
	float field = mod(floor(FRAGCOORD.y) + floor(t * 60.0), 2.0);
	color *= 1.0 - interlace_strength * field * 0.15;
	
	// ------------------------------------------------------------------------
	// ROLLING TRACKING BAR
	// A bright bar that slowly rolls down the screen
	// ------------------------------------------------------------------------
	float roll_y = fract(t * roll_speed);
	float roll_dist = abs(cuv.y - roll_y);
	float roll_bar = smoothstep(0.25, 0.0, roll_dist);
	color += roll_bar * roll_strength * vec3(0.15);
	
	// ------------------------------------------------------------------------
	// RANDOM HORIZONTAL TRACKING LINES
	// Thin lines that appear randomly across the screen
	// ------------------------------------------------------------------------
	float line_seed = y_line * 0.5 + floor(t * 8.0) * 13.0;
	float line_random = hash11(line_seed);
	float tape_line = smoothstep(0.99, 1.0, line_random) * tracking_lines;
	color += tape_line * vec3(0.2);
	
	// ------------------------------------------------------------------------
	// TAPE GRAIN / NOISE
	// ------------------------------------------------------------------------
	float grain_noise = hash12(FRAGCOORD.xy + vec2(t * 100.0, t * 80.0));
	float grain = (grain_noise - 0.5) * 2.0;
	color += grain * tape_noise * 0.08;
	
	// ------------------------------------------------------------------------
	// WHITE SPECKS (tape damage / dead pixels)
	// ------------------------------------------------------------------------
	float speck_noise = hash12(FRAGCOORD.xy * 0.6 + t * 35.0);
	float speck = smoothstep(0.998, 1.0, speck_noise);
	color += speck * white_specks * 0.4;
	
	// ------------------------------------------------------------------------
	// SIGNAL DROPOUT STATIC
	// If dropout is active, mix in heavy static noise
	// ------------------------------------------------------------------------
	if (dropout_active > 0.0) {
		float static_noise = hash12(FRAGCOORD.xy + t * 500.0);
		vec3 static_color = vec3(static_noise);
		color = mix(color, static_color, dropout_active * 0.8);
	}
	
	// ------------------------------------------------------------------------
	// CHEAP GLOW / BLOOM ON BRIGHT PIXELS
	// ------------------------------------------------------------------------
	vec3 center = color;
	vec3 glow_r = sample_screen(cuv + vec2(px.x, 0.0));
	vec3 glow_l = sample_screen(cuv - vec2(px.x, 0.0));
	vec3 glow_u = sample_screen(cuv + vec2(0.0, px.y));
	vec3 glow_d = sample_screen(cuv - vec2(0.0, px.y));
	
	vec3 blur = (center + glow_r + glow_l + glow_u + glow_d) / 5.0;
	float blur_luma = dot(blur, vec3(0.2126, 0.7152, 0.0722));
	vec3 glow = max(blur - vec3(glow_threshold), vec3(0.0));
	color += glow * glow_strength * (0.5 + 0.5 * blur_luma);
	
	// ------------------------------------------------------------------------
	// VIGNETTE
	// Darkens the corners and edges
	// ------------------------------------------------------------------------
	vec2 vig_uv = cuv - 0.5;
	float vignette = smoothstep(0.9, 0.2, dot(vig_uv, vig_uv) * 2.5);
	color *= mix(1.0 - vignette_strength, 1.0, vignette);
	
	// ------------------------------------------------------------------------
	// SPOOKY COLOR TINTS
	// ------------------------------------------------------------------------
	
	// Night vision green tint
	vec3 night_vision = vec3(0.2, 0.9, 0.3);
	color = mix(color, color * night_vision, night_vision_tint);
	
	// Decay / sickly brown-yellow tint
	vec3 decay_color = vec3(0.9, 0.75, 0.4);
	color = mix(color, color * decay_color, decay_tint);
	
	// Color temperature shift
	vec3 warm = vec3(1.1, 0.95, 0.8);
	vec3 cool = vec3(0.8, 0.9, 1.1);
	vec3 temp_shift = mix(cool, warm, color_temp * 0.5 + 0.5);
	color *= temp_shift;
	
	// ------------------------------------------------------------------------
	// APPLY FLICKER
	// ------------------------------------------------------------------------
	color *= flicker;
	
	// ------------------------------------------------------------------------
	// COLOR GRADING (brightness, contrast, saturation, gamma)
	// ------------------------------------------------------------------------
	color = apply_color_controls(color);
	
	// ------------------------------------------------------------------------
	// FINAL MASKING
	// Fade to black outside the curved screen and rounded corners
	// ------------------------------------------------------------------------
	color *= in_bounds * corner_mask;
	
	// Output the final color
	COLOR = vec4(color, 1.0);
}