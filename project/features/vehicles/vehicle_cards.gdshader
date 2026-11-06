shader_type canvas_item;
// n8 vehicles: the traffic card atlas (VehicleCards). One quad per car; the instance's custom.x
// is its cell (art id * cols + view), custom.y > 0.5 mirrors the cell about its centre (the three
// mirrored views), custom.z the wear (VehicleCards.wear: level 0 intact, 1 dented, 2 smashed,
// 3 burnt wreck, + 4 x a per-car seed). COLOR carries the tint and the blend weight (alpha).
// The wear is painted in the card's own space (value noise on the cell UV): soot-dark dents in
// the print's ink, pale scratches, and for a wreck a burnt, desaturated body with dim embers.

uniform int cols = 5;
uniform int rows = 9;
uniform vec3 ink = vec3(0.09, 0.075, 0.106);
uniform vec3 scratch = vec3(0.78, 0.76, 0.72);
uniform vec3 ember = vec3(1.0, 0.55, 0.12);

varying vec2 local;
varying vec2 nose;
varying float level;
varying float seed;

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

void vertex() {
	float cell = floor(INSTANCE_CUSTOM.x + 0.5);
	float c = mod(cell, float(cols));
	float r = floor(cell / float(cols));
	vec2 uv = UV;
	if (INSTANCE_CUSTOM.y > 0.5) {
		uv.x = 1.0 - uv.x;
	}
	local = uv;
	// The drawn view's nose in the cell (column 0 nose to the camera = down, 2 = right, 4 = up).
	float a = radians(90.0 - 45.0 * c);
	nose = vec2(cos(a) * (INSTANCE_CUSTOM.y > 0.5 ? -1.0 : 1.0), sin(a));
	float w = floor(INSTANCE_CUSTOM.z + 0.5);
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
	COLOR = col;
}
