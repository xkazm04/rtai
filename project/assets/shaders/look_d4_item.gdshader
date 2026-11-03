shader_type canvas_item;
// D4 "Ink and Hatch" (hybrid): the item pass for layers drawn ABOVE the world print (moving traffic, actors' fx, HUD,
// ghosts). Productionised from the art-direction study's look_item.gdshader mode 5 (gtai-spike artdir 821a3e7).
// Every opaque pixel snaps to the nearest D4 ink; steel prints as one flat wash value (never a dot screen, so a moving
// car matches the parked ones under the world pass); translucent ink (drop shadows) prints as a flat ink tint.
// ghost = 1: everything prints on the teal plate (the dead only).
// Blood and cop blue (palette.json, 2026-11-03) are gated plates, not nearest-ink candidates, so a mid grey
// never snaps to navy: blood when r >= BLOOD_R and max(g, b) < BLOOD_GR * r (look_noir blood_mask), cop
// blue when b - max(r, g) >= BLUE_GATE; the gates mirror palette.json `gates`.

uniform float ghost = 0.0;
uniform vec2 world_px = vec2(0.0);  // the camera's world offset in screen px: tooth and ghost dots locked to the world
uniform float shadow_k = 0.62;     // drop-shadow ink tint per unit alpha
uniform vec3 steel_out = vec3(0.640, 0.600, 0.630);   // the flat wash value steel prints at
// cells: an atlas grid for a MultiMesh whose instance custom.x is the cell (moving traffic: n-d4's
// traffic_atlas, 3 x 3); 1 x 1 = the texture as is (every other user)
uniform ivec2 cells = ivec2(1, 1);
// the output inks (palette.json paper / ink via look_profiles.json `tones`); CREAM / INK below stay the
// classification centres the art is painted in
uniform vec3 paper_tone = vec3(0.949, 0.910, 0.835);
uniform vec3 ink_tone = vec3(0.090, 0.075, 0.106);

const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 VERM = vec3(0.910, 0.314, 0.165);
const vec3 TEAL = vec3(0.122, 0.710, 0.659);
const vec3 INK = vec3(0.090, 0.075, 0.106);
const vec3 STEEL = vec3(0.561, 0.533, 0.506);
const vec3 BLOOD = vec3(0.639, 0.020, 0.035);
const vec3 BLOOD_DARK = vec3(0.329, 0.000, 0.020);
const vec3 COP_BLUE = vec3(0.227, 0.278, 0.400);
const vec3 COP_BLUE_HI = vec3(0.310, 0.525, 0.878);
const float BLOOD_R = 0.30;
const float BLOOD_GR = 0.18;
const float BLUE_GATE = 0.08;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float dots(vec2 frag, float cov, float ang) {
	vec2 p = mat2(vec2(cos(ang), sin(ang)), vec2(-sin(ang), cos(ang))) * frag / 2.0;
	return step(length(fract(p) - 0.5), sqrt(cov / 3.14159));
}

void vertex() {
	if (cells.x * cells.y > 1) {
		float cell = floor(INSTANCE_CUSTOM.x + 0.5);
		UV = (UV + vec2(mod(cell, float(cells.x)), floor(cell / float(cells.x)))) / vec2(cells);
	}
}

void fragment() {
	vec4 c = COLOR;
	vec2 px = FRAGCOORD.xy + world_px;
	float g = 1.0 - 0.06 * hash(floor(px));
	if (c.a < 0.02) discard;
	if (ghost > 0.5) {
		float l = dot(c.rgb, vec3(0.333));
		if (l < 0.3) { COLOR = vec4(TEAL * 0.62 * g, 1.0); }
		else if (dots(px, 0.6, 1.31) > 0.5) { COLOR = vec4(TEAL * g, 1.0); }
		else discard;
	} else if (c.a < 0.75) {
		COLOR = vec4(ink_tone, c.a * shadow_k);
	} else if (c.r >= BLOOD_R && max(c.g, c.b) < BLOOD_GR * c.r) {
		COLOR = vec4(mix(BLOOD_DARK, BLOOD, step(0.48, c.r)) * g, 1.0);
	} else if (c.b - max(c.r, c.g) >= BLUE_GATE) {
		float hi = step(distance(c.rgb, COP_BLUE_HI), distance(c.rgb, COP_BLUE));
		COLOR = vec4(mix(COP_BLUE, COP_BLUE_HI, hi) * g, 1.0);
	} else {
		vec3 col = c.rgb;
		vec3 o = paper_tone;
		float best = distance(col, CREAM);
		float ds = distance(col, STEEL);
		if (ds < best) { best = ds; o = steel_out; }
		float di = distance(col, INK);
		if (di < best) { best = di; o = ink_tone; }
		float dv = distance(col, VERM);
		if (dv < best) { best = dv; o = VERM; }
		float dt = distance(col, TEAL);
		if (dt < best) { o = TEAL; }
		COLOR = vec4(o * g, 1.0);
	}
}
