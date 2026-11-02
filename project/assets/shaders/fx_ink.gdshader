shader_type canvas_item;
// Placeholder FX sprites (core/render/README.md, data/tables/fx.json) drawn analytically per MultiMesh instance
// until d4-production delivers the FX sheet. Flat palette inks, hard edges, an ink rim: they print like the item
// pass (no gradients). INSTANCE_CUSTOM.x = shape (0 disc, 1 streak, 2 burst, 3 splat, 4 bolt), .y = a per-particle
// seed. COLOR = the token ink with alpha = the fade (cut to a dither, never a soft alpha ramp).

varying vec4 custom;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void vertex() {
	custom = INSTANCE_CUSTOM;
}

float shape_mask(vec2 p, int shape, float seed) {
	float r = length(p);
	float a = atan(p.y, p.x);
	if (shape == 1) {   // streak: a long thin capsule along +x
		return step(abs(p.y), 0.12 * (1.0 - abs(p.x))) * step(abs(p.x), 1.0);
	}
	if (shape == 2) {   // burst: a 6-point star
		float spikes = 0.45 + 0.5 * pow(abs(cos(a * 3.0 + seed * 6.28)), 6.0);
		return step(r, spikes);
	}
	if (shape == 3) {   // splat: a lumpy blob
		float lump = 0.55 + 0.18 * sin(a * 5.0 + seed * 20.0) + 0.12 * sin(a * 9.0 + seed * 7.0);
		return step(r, lump);
	}
	if (shape == 4) {   // bolt: a zigzag stroke along +x
		float zig = abs(fract(p.x * 2.5 + seed) - 0.5) * 0.8 - 0.2;
		return step(abs(p.y - zig), 0.09) * step(abs(p.x), 0.95);
	}
	return step(r, 0.8);   // disc
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	int shape = int(custom.x + 0.5);
	float m = shape_mask(p, shape, custom.y);
	float inner = shape_mask(p * 1.18, shape, custom.y);
	float keep = step(hash(floor(FRAGCOORD.xy / 2.0)), COLOR.a);
	vec3 ink = vec3(0.090, 0.075, 0.106);
	vec3 col = mix(ink, COLOR.rgb, inner);
	COLOR = vec4(col, m * keep);
}
