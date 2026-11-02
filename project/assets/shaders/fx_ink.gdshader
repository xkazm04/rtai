shader_type canvas_item;
// Placeholder FX sprites (core/render/README.md, data/tables/fx.json) drawn analytically per MultiMesh instance
// until d4-production delivers the FX sheet. Flat palette inks, hard edges, an ink rim: they print like the item
// pass (no gradients). INSTANCE_CUSTOM.x = shape (0 disc, 1 streak, 2 burst, 3 splat, 4 bolt), .y = a per-particle
// seed, .z = the FX sheet cell + 1 (0 = draw the analytic shape). COLOR = the token ink with alpha = the fade (cut to
// a dither, never a soft alpha ramp). A sheet cell keeps its own inks and is cut at alpha 0.5 (no soft edge).

uniform sampler2D atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform vec2 grid = vec2(1.0);
uniform vec2 world_px = vec2(0.0);  // camera world offset in screen px: the fade dither is world-locked

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

vec4 sheet(float cell_plus1, vec2 uv, float keep) {
	float c = floor(cell_plus1 - 0.5);
	vec2 cell = vec2(mod(c, grid.x), floor(c / grid.x));
	vec4 tex = texture(atlas, (cell + clamp(uv, vec2(0.004), vec2(0.996))) / grid);
	return vec4(tex.rgb, step(0.5, tex.a) * keep);
}

void fragment() {
	float keep = step(hash(floor((FRAGCOORD.xy + world_px) / 2.0)), COLOR.a);
	if (custom.z > 0.5) {
		COLOR = sheet(custom.z, UV, keep);
	} else {
		vec2 p = UV * 2.0 - 1.0;
		int shape = int(custom.x + 0.5);
		float m = shape_mask(p, shape, custom.y);
		float inner = shape_mask(p * 1.18, shape, custom.y);
		vec3 ink = vec3(0.090, 0.075, 0.106);
		COLOR = vec4(mix(ink, COLOR.rgb, inner), m * keep);
	}
}
