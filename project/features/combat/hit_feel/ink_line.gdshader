// n12 C1: the struck figure's ink line, pressed harder for a few ticks (InkHit). Draws its texture as it
// is (the card's own art) and inks every pixel whose ring at radius w crosses the alpha edge, on both sides,
// so the outline thickens by about 2 w. w = hit_edge screen px, wobbling on a 3-texel lattice of the
// figure itself (a pen line drawn on it, it moves with it). Only a struck card carries this material.
shader_type canvas_item;

uniform float hit_edge = 0.0;
uniform float alpha_cut = 0.45;
uniform vec2 cells = vec2(1.0);  // the card's frame grid (hframes, vframes): the ring never reads a neighbour frame

const vec3 INK = vec3(0.106, 0.082, 0.090);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	vec4 c = COLOR;
	vec2 uvp = vec2(max(length(dFdx(UV)), length(dFdy(UV))));
	vec2 texel = floor(UV / TEXTURE_PIXEL_SIZE / 3.0);
	float w = hit_edge * (0.7 + 0.6 * hash(texel));
	float in_k = 0.0;
	float out_k = 0.0;
	vec2 cell = 1.0 / cells;
	vec2 lo = floor(UV * cells) * cell + TEXTURE_PIXEL_SIZE * 0.5;
	vec2 hi = lo + cell - TEXTURE_PIXEL_SIZE;
	for (int k = 0; k < 8; k++) {
		float an = float(k) * 0.785398;
		vec2 at = clamp(UV + vec2(cos(an), sin(an)) * uvp * w, lo, hi);
		float a = texture(TEXTURE, at).a;
		in_k = max(in_k, step(alpha_cut, a));
		out_k = max(out_k, step(a, alpha_cut));
	}
	bool me = c.a >= alpha_cut;
	if (hit_edge > 0.0 && ((!me && in_k > 0.5) || (me && out_k > 0.5))) {
		COLOR = vec4(INK, 1.0);
	} else {
		COLOR = c;
	}
}
