shader_type canvas_item;
// n8 vehicles: the traffic card atlas (VehicleCards). One quad per car; the instance's custom.x
// is its cell (art id * cols + view), custom.y > 0.5 mirrors the cell about its centre (the three
// mirrored views), custom.z the wear (VehicleCards.wear: level 0 intact, 1 dented, 2 smashed,
// 3 burnt wreck, + 4 x a per-car seed). COLOR carries the tint and the blend weight (alpha).
// The wear is painted in the card's own space (value noise on the cell UV): soot-dark dents in
// the print's ink, pale scratches, and for a wreck a burnt, desaturated body with dim embers.
// custom.z >= siren_bit (VehicleCards.SIREN): the light bar flashes, its blue and amber lenses
// (found by colour in the cell's top band, so the amber tail lamps never flash) lit in turn.

uniform int cols = 5;
uniform int rows = 9;
uniform vec3 ink = vec3(0.09, 0.075, 0.106);
uniform vec3 scratch = vec3(0.78, 0.76, 0.72);
uniform vec3 ember = vec3(1.0, 0.55, 0.12);
uniform float siren_bit = 256.0;
uniform float siren_hz = 2.2;
uniform float lens_band = 0.45;
uniform float glow_px = 16.0;
uniform float glow_k = 0.9;

varying vec2 local;
varying vec2 nose;
varying float level;
varying float seed;
varying float siren;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	return 0.55 * vnoise(p) + 0.3 * vnoise(p * 2.3) + 0.15 * vnoise(p * 5.1);
}

// 1 for a blue lens pixel, 2 for an amber one, 0 otherwise.
float lens(vec3 c) {
	if (c.b > 0.6 && c.b > c.r + 0.3 && c.b > c.g + 0.2) {
		return 1.0;
	}
	return (c.r > 0.6 && c.r > c.g + 0.2 && c.g > c.r * 0.2 && c.b < c.r * 0.35) ? 2.0 : 0.0;
}

// A light-bar lens pixel lit (its half of the cycle: blue first, then amber) or dimmed.
vec3 flash(vec3 c, float phase) {
	float k = lens(c);
	if (k < 0.5) {
		return c;
	}
	bool blue = k < 1.5;
	bool lit = blue ? phase < 0.5 : phase >= 0.5;
	vec3 hot = blue ? vec3(0.55, 0.75, 1.0) : vec3(1.0, 0.86, 0.5);
	return lit ? mix(c, hot, 0.7) : c * 0.4;
}

void vertex() {
	float cell = floor(INSTANCE_CUSTOM.x + 0.5);
	float c = mod(cell, float(cols));
	float r = floor(cell / float(cols));
	vec2 uv = UV;
	if (INSTANCE_CUSTOM.y > 0.5) {
		uv.x = 1.0 - uv.x;
	}
	local = uv;
	// The drawn view's nose in the cell (column 0 nose to the camera = down, 2 = right, 4 = up;
	// columns 5-8 the in-betweens, 22.5 degrees past columns 0-3).
	float a = radians(c < 4.5 ? 90.0 - 45.0 * c : 67.5 - 45.0 * (c - 5.0));
	nose = vec2(cos(a) * (INSTANCE_CUSTOM.y > 0.5 ? -1.0 : 1.0), sin(a));
	float w = floor(INSTANCE_CUSTOM.z + 0.5);
	siren = w >= siren_bit ? 1.0 : 0.0;
	w = mod(w, siren_bit);
	level = mod(w, 4.0);
	seed = floor(w / 4.0);
	UV = (uv + vec2(c, r)) / vec2(float(cols), float(rows));
}

void fragment() {
	vec4 col = texture(TEXTURE, UV) * COLOR;
	if (level > 0.5 && col.a > 0.0) {
		vec2 o = vec2(mod(seed * 7.31, 61.0), mod(seed * 3.17, 53.0));
		vec2 p = local - 0.5;
		// The crumple zone: 1 at the nose end of the body, 0 behind the middle.
		float front = clamp(dot(p, nose) * 4.0 + 0.2, 0.0, 1.0);
		float n = fbm(local * 30.0 + o);
		// Scratches run along the body (short streaks on the long axis).
		vec2 ax = vec2(dot(p, nose), dot(p, vec2(-nose.y, nose.x)));
		float s = vnoise(ax * vec2(16.0, 110.0) + o.yx);
		// level 1: dents at the nose; 2: deeper and spread, the paint dulled; 3: burnt out.
		float reach = level > 2.5 ? 1.0 : (level > 1.5 ? 0.45 : 0.0);
		float w = mix(front, 1.0, reach);
		float lo = level > 2.5 ? 0.44 : (level > 1.5 ? 0.5 : 0.56);
		float k = level > 2.5 ? 0.85 : (level > 1.5 ? 0.82 : 0.7);
		float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114));
		float dull = level > 2.5 ? 0.85 : (level > 1.5 ? 0.3 : 0.0);
		float val = level > 2.5 ? 0.56 : (level > 1.5 ? 0.88 : 1.0);
		col.rgb = mix(col.rgb, vec3(grey), dull) * val;
		float dent = smoothstep(lo, lo + 0.07, n * (0.55 + 0.5 * w)) * k;
		col.rgb = mix(col.rgb, ink, dent);
		if (level < 2.5) {
			float bare = 1.0 - dent;
			col.rgb = mix(col.rgb, scratch, smoothstep(0.84, 0.88, s) * 0.6 * bare * w);
		} else {
			float e = smoothstep(0.78, 0.84, fbm(local * 40.0 + o.yx));
			col.rgb = mix(col.rgb, ember, e * 0.6);
		}
	}
	if (siren > 0.5 && local.y < lens_band) {
		// The lit lens's glow round it: 16 taps on two rings (TEXTURE is a stage built-in, so the
		// taps sit here, not in a function).
		float phase = fract(TIME * siren_hz + seed * 0.37);
		float want = phase < 0.5 ? 1.0 : 2.0;
		float hits = 0.0;
		for (int i = 0; i < 16; i++) {
			float a = float(i) * 0.785398 + (i < 8 ? 0.0 : 0.392699);
			vec2 o = vec2(cos(a), sin(a)) * TEXTURE_PIXEL_SIZE * glow_px * (i < 8 ? 0.5 : 1.0);
			vec4 t = texture(TEXTURE, UV + o);
			hits += (t.a > 0.5 && abs(lens(t.rgb) - want) < 0.5) ? 1.0 : 0.0;
		}
		vec3 hue = want < 1.5 ? vec3(0.45, 0.7, 1.0) : vec3(1.0, 0.75, 0.3);
		float g = min(hits / 3.0, 1.0) * glow_k;
		col.rgb = mix(flash(col.rgb, phase), hue, g * 0.6 * col.a);
		col.rgb = mix(hue, col.rgb, col.a);
		col.a = max(col.a, g * 0.7 * COLOR.a);
	}
	COLOR = col;
}
