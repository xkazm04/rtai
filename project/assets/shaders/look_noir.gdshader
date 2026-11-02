shader_type canvas_item;
// D-Noir: the high-contrast noir comic print pass (a parallel direction to D4; lane `noir`, 2026-11-02).
// A full-screen pass over EVERYTHING (the D4-printed world and the actors), reading the frame through the
// screen texture. Params are data: look_noir.params.json `frame` (core: one table of uniforms).
//  - value is thresholded to pure ink / pure paper; blacks below `crush` are crushed to solid ink
//  - the narrow mid band prints as diagonal pen strokes, never as a flat grey (grey used sparingly)
//  - dark-on-dark silhouette edges that face the light print as a WHITE rim (carved by the light)
//  - the vermilion plate (D4 threats, cops, Rivet's collar) prints at verm_value (ink): a black mass with the
//    art's cream sticker rim turned to a white rim - danger reads by value and shape, not hue
//  - blood (deep arterial red, g/r low) is a protected channel: it survives the pass as BLOOD, the one colour
//  - teal (the dead) survives as a flat teal plate; everything else is black and white
//  - rain: sparse world-locked streaks and landing splash rings, white over ink and ink over paper; paper fibre grain on the whites
// world_px: the camera's world offset in screen px (set every frame); rain_phase: advances with the sim tick.

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 world_px = vec2(0.0);
uniform float rain_phase = 0.0;
uniform float amount = 1.0;        // 0 = the input frame, 1 = full noir
uniform float thresh = 0.46;       // luminance under which a pixel prints as ink
uniform float soft = 0.025;        // half-width of the ink/paper edge (anti-aliasing only)
uniform float crush = 0.30;        // luminance under which everything is solid ink (no strokes, no rim)
uniform float band = 0.07;         // the mid band (thresh +- band) prints as pen strokes
uniform float stroke_period = 3.0;
uniform float rim = 1.0;           // white rim on dark silhouette edges facing the light
uniform float rim_lo = 0.035;      // luminance gradient where the rim starts / is full
uniform float rim_hi = 0.10;
uniform vec2 light_dir = vec2(-0.6, -0.8);  // where the light comes FROM (screen space, y down)
uniform float edge_ink = 0.9;      // ink outline on bright-side edges
uniform float rain = 0.55;         // rain streak density 0..1
uniform float rain_len = 22.0;     // streak length in px
uniform float rain_slant = 0.18;   // x drift per px of fall
uniform float splash = 0.0;        // share of splash cells with a drop landing each cycle (0 = off)
uniform float splash_cell = 28.0;  // splash cell size in screen px (one landing spot per cell per cycle)
uniform float splash_period = 36.0; // rain_phase ticks per cycle; a splash ring lives 7 of them
uniform float grain = 0.06;        // paper fibre on the whites
uniform float vignette = 0.35;     // ink pulled in from the frame edges (a panel border feeling)
uniform float verm_value = 0.0;    // the value the vermilion plate prints at: 0 = a solid ink mass, 1 = paper
uniform float blood = 1.0;         // the protected red channel
uniform float teal = 1.0;

const vec3 PAPER = vec3(0.945, 0.937, 0.910);
const vec3 INK = vec3(0.027, 0.027, 0.035);
const vec3 BLOOD = vec3(0.640, 0.020, 0.035);
const vec3 BLOOD_DARK = vec3(0.330, 0.000, 0.020);
const vec3 TEAL = vec3(0.122, 0.710, 0.659);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float lum(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

// deep arterial red: strong red, almost no green or blue (D4 vermilion has g/r ~ 0.35 and is NOT blood)
float blood_mask(vec3 c) {
	float gr = max(c.g, c.b) / max(c.r, 0.001);
	return smoothstep(0.30, 0.42, c.r) * (1.0 - smoothstep(0.14, 0.22, gr));
}

float verm_mask(vec3 c) {
	return clamp((c.r - max(c.g, c.b) - 0.12) * 2.6, 0.0, 1.0) * (1.0 - blood_mask(c));
}

float teal_mask(vec3 c) { return clamp((min(c.g, c.b) - c.r - 0.08) * 2.8, 0.0, 1.0); }

// the value the threshold reads: vermilion lifted to paper, blood and teal handled as plates
float value_of(vec3 c) {
	return mix(lum(c), verm_value, verm_mask(c));
}

float value_at(vec2 uv) { return value_of(texture(screen_tex, uv).rgb); }

float rain_mask(vec2 w) {
	float x = w.x - w.y * rain_slant;
	float col = floor(x / 3.0);
	float on = step(1.0 - rain * 0.35, hash(vec2(col, 7.3)));
	float y = w.y + rain_phase * (9.0 + 5.0 * hash(vec2(col, 1.1)));
	float seg = fract(y / (rain_len * 4.0) + hash(vec2(col, 3.7)));
	float line = 1.0 - smoothstep(0.35, 0.9, abs(fract(x / 3.0) - 0.5) * 2.0);
	return on * step(seg, 0.25) * line;
}

// a drop landing: a ring that grows and fades over 7 ticks, at a new spot of its cell every cycle
float splash_mask(vec2 w) {
	vec2 cell = floor(w / splash_cell);
	float t = rain_phase / splash_period + hash(cell + 5.5);
	float cyc = floor(t);
	float age = fract(t) * splash_period;
	float on = step(1.0 - splash, hash(cell + cyc * 1.37 + 31.7));
	vec2 c = (cell + 0.25 + 0.5 * vec2(hash(cell + cyc + 3.1), hash(cell + cyc + 9.4))) * splash_cell;
	float rad = 1.2 + age * 0.8;
	float ring = 1.0 - smoothstep(0.7, 1.5, abs(length(w - c) - rad));
	return on * step(age, 7.0) * ring * (1.0 - age / 12.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 tx = SCREEN_PIXEL_SIZE;
	vec2 w = FRAGCOORD.xy + world_px;
	vec3 src = texture(screen_tex, uv).rgb;
	float v = value_of(src);
	// threshold: crushed ink, the stroke band, paper
	float paper = smoothstep(thresh - soft, thresh + soft, v);
	float in_band = 1.0 - smoothstep(band * 0.6, band, abs(v - thresh));
	float st = abs(fract((w.x + w.y) / stroke_period) - 0.5) * 2.0;
	float cov = clamp((v - (thresh - band)) / (2.0 * band), 0.0, 1.0);
	paper = mix(paper, step(1.0 - cov, st), in_band);
	paper *= step(crush, v);
	// gradient of the value: ink outlines on lit edges, a white rim on dark-on-dark edges facing the light
	float vr = value_at(uv + vec2(tx.x, 0.0));
	float vl = value_at(uv - vec2(tx.x, 0.0));
	float vd = value_at(uv + vec2(0.0, tx.y));
	float vu = value_at(uv - vec2(0.0, tx.y));
	vec2 g = vec2(vr - vl, vd - vu);
	float e = length(g);
	float facing = clamp(dot(normalize(g + vec2(1e-5)), normalize(light_dir)), 0.0, 1.0);
	// the rim only where BOTH sides are ink (a dark silhouette on a dark ground), so lit shapes keep one line
	float nb_max = max(max(vr, vl), max(vd, vu));
	float dark_dark = 1.0 - smoothstep(thresh - 0.04, thresh + 0.02, nb_max);
	float r = smoothstep(rim_lo, rim_hi, e) * dark_dark * (0.25 + 0.75 * facing) * rim;
	paper = max(paper, r);
	float dark = 1.0 - smoothstep(thresh - 0.02, thresh + 0.06, v);
	paper *= 1.0 - smoothstep(0.18, 0.40, e) * (1.0 - dark) * edge_ink;
	// rain: white over ink, ink over paper
	float rm = rain_mask(w);
	paper = mix(paper, 1.0 - paper, rm * 0.85);
	paper = mix(paper, 1.0 - paper, splash_mask(w) * step(0.001, splash));
	vec3 col = mix(INK, PAPER * (1.0 - grain * vnoise(w * 0.7) - grain * 0.5 * hash(floor(w))), paper);
	// vignette: ink in from the edges
	vec2 q = uv * 2.0 - 1.0;
	col *= 1.0 - vignette * smoothstep(0.55, 1.25, length(q * vec2(0.85, 1.0)));
	// protected plates: teal (the dead), then blood (the one colour) - blood darkens in its own shadow
	col = mix(col, TEAL, smoothstep(0.30, 0.45, teal_mask(src)) * teal);
	float b = blood_mask(src);
	vec3 bc = mix(BLOOD_DARK, BLOOD, smoothstep(0.35, 0.6, src.r));
	col = mix(col, bc, smoothstep(0.25, 0.6, b) * blood);
	COLOR = vec4(mix(src, col, amount), 1.0);
}
