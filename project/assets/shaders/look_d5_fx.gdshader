shader_type canvas_item;
// n5-look 2026-11-04 (target r2_w4_fx_colour, "the effects in colour, no blood red"): the item print for
// Rivet's weapon FX cells (WeaponFxColour). look_d4_item snaps every pixel to the nearest ink, so the
// round 2 colour cells printed vermilion (orange), cream (yellow, violet-white) or teal (green). Here the
// cell keeps its own colour: the ink outline prints the page ink, near-cream the page paper, and the
// colour fills take the riso print's world-locked halftone (dot_k, mean kept) and paper tooth (grain).
// Guards: a blood-gated pixel (palette.json blood gate) is pushed to orange (red is blood only), and a
// teal-hued pixel to cyan-white (teal is souls only). Faded cells keep their alpha (look_d4_item turned
// alpha < 0.75 into a flat ink tint, so a fading fireball printed as a grey ring).
// Uniforms: look_d5.params.json `fx` (WeaponFxColour); world_px from the actors' item print.
uniform vec2 world_px = vec2(0.0);
uniform vec3 paper_tone = vec3(0.949, 0.910, 0.835);
uniform vec3 ink_tone = vec3(0.090, 0.075, 0.106);
uniform float ink_snap = 0.16;    // distance to INK under which a pixel prints the page ink
uniform float paper_snap = 0.06;  // distance to CREAM under which a pixel prints the page paper
uniform float dot_k = 0.22;       // halftone contrast in the colour mid-tones (0 = flat)
uniform float dot_period = 4.0;   // screen px between dot centres (the world riso's screen)
uniform float grain = 0.06;       // paper tooth (the world print's 0.05 hash)
uniform float sat = 1.0;          // colour saturation (1 = the cell's own)
const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 INK = vec3(0.090, 0.075, 0.106);
const vec3 TEAL = vec3(0.122, 0.710, 0.659);
const float BLOOD_R = 0.30;
const float BLOOD_GR = 0.18;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

// a 45-degree dot screen: 1 inside the dot of coverage cov at screen point p
float dot_at(vec2 p, float cov) {
	vec2 q = mat2(vec2(0.7071, 0.7071), vec2(-0.7071, 0.7071)) * p / dot_period;
	return step(length(fract(q) - 0.5), sqrt(cov / 3.14159));
}

void fragment() {
	vec4 c = COLOR;
	if (c.a < 0.02) discard;
	vec2 px = FRAGCOORD.xy + world_px;
	vec3 col = c.rgb;
	if (distance(col, INK) < ink_snap) {
		col = ink_tone;
	} else if (distance(col, CREAM) < paper_snap) {
		col = paper_tone;
	} else {
		if (col.r >= BLOOD_R && max(col.g, col.b) < BLOOD_GR * col.r) {
			col.g = col.r * 0.5;  // never blood red: push to orange
		}
		if (distance(col, TEAL) < 0.25) {
			col = mix(col, vec3(0.85, 0.97, 1.0), 0.7);  // never teal: cyan-white
		}
		float lum = dot(col, vec3(0.299, 0.587, 0.114));
		col = mix(vec3(lum), col, sat);
		float mid = 1.0 - abs(lum - 0.55) * 2.0;
		float cov = 0.5;
		col *= 1.0 + dot_k * clamp(mid, 0.0, 1.0) * (cov - dot_at(px, cov));
	}
	col *= 1.0 - grain * hash(floor(px) + vec2(17.0, 31.0));
	COLOR = vec4(clamp(col, 0.0, 1.0), c.a);
}
