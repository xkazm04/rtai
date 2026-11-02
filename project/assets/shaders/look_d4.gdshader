shader_type canvas_item;
// D4 "Ink and Hatch" (hybrid): the full-screen print pass for the world layer (ground, roofs, props, parked cars).
// Productionised from the art-direction study's wash pass (look.gdshader mode 5, gtai-spike artdir 821a3e7).
// The pen work comes from the D4 art; this pass sets the TONE BUDGET:
//  - ink density (from luminance) prints as paper / light wash / mid wash / dark wash, flat steps with soft borders
//  - the art's own ink lines (density above line_ink) print as solid ink, so drawn hatching survives the budget
//  - hatching is added only in the deepest shadows; a wobbly Sobel edge inks object outlines
//  - vermilion and teal are flat plates, slightly off-register (the colour doctrine lives in the assets)
// Every uniform below except world_px is a look-profile parameter (data/tables/look_profiles.json, core/render).
// world_px: the camera's world offset in screen px (set every frame), so grime and hatch are locked to the world.
// Use: a full-rect ColorRect on a CanvasLayer between the world and the actors; the actor / fx / HUD layers above it
// use look_d4_item.gdshader. Defaults are the F-08 tuning + the f08b charcoal-street retune (crop gates at 32 and 48 px/m, 2026-11-02).

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 world_px = vec2(0.0);
uniform vec2 verm_shift = vec2(2.0, -1.0);
uniform vec2 teal_shift = vec2(-1.0, 2.0);
uniform float grime = 0.15;        // 0..1: low-frequency wash blotches (1 = the study's full grime)
uniform float step_lo = 0.19;      // ink density where the light wash starts
uniform float step_mid = 0.45;     // ... the mid wash
uniform float step_hi = 0.68;      // ... the dark wash
uniform float wash_lo = 0.30;      // wash strengths (0 = paper, 1 = the wash ink)
uniform float wash_mid = 0.90;
uniform float wash_hi = 0.30;      // the dark step mixes the wash ink toward INK by this
uniform float line_ink = 0.90;     // density above which the art's own lines print as solid ink
uniform float edge_lo = 0.13;      // Sobel ink-outline thresholds (luminance gradient)
uniform float edge_hi = 0.32;
uniform float hatch_on = 0.86;     // deep-shadow hatching starts at this density
uniform float hatch_period = 4.0;  // pen-stroke spacing in screen px (D5 widens it up close)
uniform float grit = 0.35;         // paper stipple (0..1)
uniform float verm = 0.92;
uniform float teal = 0.85;

const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 VERM = vec3(0.910, 0.314, 0.165);
const vec3 TEAL = vec3(0.122, 0.710, 0.659);
const vec3 INK = vec3(0.090, 0.075, 0.106);
const vec3 WASH = vec3(0.400, 0.372, 0.408);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

// x = ink density, y = vermilion density, z = teal density
vec3 plates(vec3 c) {
	float lum = dot(c, vec3(0.299, 0.587, 0.114));
	float v = clamp((c.r - max(c.g, c.b) - 0.12) * 2.6, 0.0, 1.0);
	float t = clamp((min(c.g, c.b) - c.r - 0.08) * 2.8, 0.0, 1.0);
	float ink = clamp((0.93 - lum) * 1.25 - v * 0.55 - t * 0.55, 0.0, 1.0);
	return vec3(ink, v, t);
}

float lum3(vec2 uv) { return dot(texture(screen_tex, uv).rgb, vec3(0.333)); }

float sobel(vec2 uv, vec2 tx) {
	float gx = lum3(uv + vec2(tx.x, 0.0)) - lum3(uv - vec2(tx.x, 0.0));
	float gy = lum3(uv + vec2(0.0, tx.y)) - lum3(uv - vec2(0.0, tx.y));
	return length(vec2(gx, gy));
}

// one family of parallel pen strokes with coverage cov (0..1) and a hand wobble
float strokes(vec2 w, float ang, float period, float cov) {
	vec2 dir = vec2(cos(ang), sin(ang));
	float along = dot(w, vec2(-dir.y, dir.x));
	float across = dot(w, dir) + (vnoise(vec2(along * 0.045, ang * 7.0)) - 0.5) * 1.6;
	float f = abs(fract(across / period) - 0.5) * 2.0;
	float gap = step(0.12, vnoise(vec2(along * 0.11, floor(across / period) * 3.7)));
	return (1.0 - smoothstep(cov - 0.12, cov + 0.12, f)) * smoothstep(0.0, 0.08, cov) * gap;
}

void fragment() {
	vec2 w = FRAGCOORD.xy + world_px;
	vec2 uv = SCREEN_UV;
	vec2 tx = SCREEN_PIXEL_SIZE;
	vec3 p0 = plates(texture(screen_tex, uv).rgb);
	float vden = plates(texture(screen_tex, uv + verm_shift * tx).rgb).y;
	float tden = plates(texture(screen_tex, uv + teal_shift * tx).rgb).z;
	float d = p0.x;
	float g = ((vnoise(w * 0.035) - 0.5) * 0.22 + (vnoise(w * 0.11) - 0.5) * 0.10) * grime;
	float t = clamp(d + g, 0.0, 1.0);
	vec3 col = CREAM;
	col = mix(col, mix(CREAM, WASH, wash_lo), smoothstep(step_lo - 0.03, step_lo + 0.03, t));
	col = mix(col, mix(CREAM, WASH, wash_mid), smoothstep(step_mid - 0.03, step_mid + 0.03, t));
	col = mix(col, mix(WASH, INK, wash_hi), smoothstep(step_hi - 0.03, step_hi + 0.03, t));
	float ink = strokes(w, 0.785, hatch_period, smoothstep(hatch_on - 0.02, 0.95, d) * 0.36);
	ink = max(ink, strokes(w, 2.356, hatch_period, smoothstep(0.93, 0.99, d) * 0.30));
	ink = max(ink, smoothstep(line_ink, line_ink + 0.06, d));
	float e = sobel(uv, tx);
	ink = max(ink, smoothstep(edge_lo + 0.12 * vnoise(w * 0.2), edge_hi, e) * (0.75 + 0.25 * vnoise(w * 0.5)));
	col = mix(col, VERM, smoothstep(0.26, 0.40, vden + (vnoise(w * 0.3) - 0.5) * 0.12) * verm);
	col = mix(col, TEAL, smoothstep(0.30, 0.45, tden) * teal);
	col = mix(col, INK, ink);
	col = mix(col, INK, step(0.985, hash(floor(w))) * 0.5 * grit);
	// paper tooth, world-locked like the grime (was hash(FRAGCOORD): a screen-door that swam on pans)
	COLOR = vec4(col * (1.0 - 0.05 * hash(floor(w) + vec2(17.0, 31.0))), 1.0);
}
