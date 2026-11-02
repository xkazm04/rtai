shader_type canvas_item;
// D5 "Inked Grime": a print layer OVER the D4 world print (look_d4.gdshader), under the actors. It reads the
// already-printed D4 frame and adds what the Rivet concept has and D4 does not:
//  - ink pressure: the wash steps get a second, world-locked pen hatch whose stroke weight wanders (heavier
//    in the darks), so flat washes read as drawn, not filled
//  - paper grain: a mottled, world-locked tooth that lifts ink a little and darkens paper a little
//  - misregistration: the ink plate prints a faint ghost shifted by ink_mis px, and the vermilion plate a second
//    pass shifted by verm_mis px (the concept's off-register red edges)
// Everything is scaled by `amount` = the zoom blend (look_d5.params.json "zoom_amount": none at 32 px/m, so the
// gameplay frame stays exactly D4; it builds from 48 px/m up to full at 64 px/m). The colour doctrine is untouched:
// the layer only moves ink and vermilion that the D4 print already put there.
// world_px: as look_d4 (the camera's world offset in screen px), so grain and hatch are locked to the world.

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 world_px = vec2(0.0);
uniform float amount = 1.0;
uniform float hatch = 0.45;        // second hatch family strength in the wash steps
uniform float hatch_period = 6.0;  // screen px between strokes
uniform float wash_lo = 0.22;      // the hatch lives in the wash between these densities
uniform float wash_hi = 0.55;      // (the charcoal street sits above wash_hi and stays a calm field)
uniform float street_hatch = 0.55; // sparse darker strokes on the charcoal street (full at 64 px/m+)
uniform float street_hatch_car = 0.4; // share of it already printed at the car camera (48 px/m, amount ~0.35)
uniform float grain = 0.5;         // paper tooth strength
uniform vec2 ink_mis = vec2(1.0, 1.0);
uniform float ink_ghost = 0.22;    // strength of the off-register ink ghost
uniform vec2 verm_mis = vec2(-2.0, 1.0);
uniform float verm_ghost = 0.65;   // strength of the off-register vermilion pass
uniform float age = 0.0;           // aged paper: warms the neutral print toward the mock's sepia (0 = off)

const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 VERM = vec3(0.910, 0.314, 0.165);
const vec3 INK = vec3(0.090, 0.075, 0.106);
// aged-paper gains, dark end and light end (d4h2_mock.jpg medians: street 78,67,68 / paper 246,223,195)
const vec3 AGE_DARK = vec3(1.03, 0.955, 0.87);
const vec3 AGE_LIGHT = vec3(1.065, 1.0, 0.955);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float dens(vec3 c) { return clamp((0.93 - dot(c, vec3(0.299, 0.587, 0.114))) * 1.2, 0.0, 1.0); }

float vden(vec3 c) { return clamp((c.r - max(c.g, c.b) - 0.25) * 3.0, 0.0, 1.0); }

float strokes(vec2 w, float ang, float cov) {
	vec2 dir = vec2(cos(ang), sin(ang));
	float along = dot(w, vec2(-dir.y, dir.x));
	float across = dot(w, dir) + (vnoise(vec2(along * 0.03, ang * 3.0)) - 0.5) * 2.0;
	float f = abs(fract(across / hatch_period) - 0.5) * 2.0;
	float press = 0.55 + 0.9 * vnoise(vec2(along * 0.025, floor(across / hatch_period) * 1.7));
	float gap = step(0.18, vnoise(vec2(along * 0.07, floor(across / hatch_period) * 4.1)));
	return (1.0 - smoothstep(cov * press - 0.12, cov * press + 0.12, f)) * gap;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 tx = SCREEN_PIXEL_SIZE;
	vec2 w = FRAGCOORD.xy + world_px;
	vec3 c = texture(screen_tex, uv).rgb;
	if (amount < 0.004) {
		COLOR = vec4(c, 1.0);
	} else {
		float d = dens(c);
		bool is_verm = vden(c) > 0.3;
		vec3 o = c;
		// ink pressure: a second family over the mid and dark wash (never on paper, never on solid ink)
		float wash = smoothstep(wash_lo, wash_lo + 0.12, d) * (1.0 - smoothstep(wash_hi, wash_hi + 0.1, d));
		float patch = smoothstep(0.42, 0.72, vnoise(w * 0.018 + 7.0));   // hand pressure comes and goes in patches
		float h = strokes(w, -0.62, mix(0.16, 0.34, smoothstep(0.3, 0.6, d))) * wash * patch * hatch;
		if (!is_verm) o = mix(o, INK, h * amount);
		// the street (dark wash): sparse, darker pen strokes, only at full amount (64 px/m+), the mock's hatched asphalt
		float street = smoothstep(wash_hi + 0.05, wash_hi + 0.15, d) * (1.0 - smoothstep(0.88, 0.95, d));
		float hs = strokes(w + vec2(3.0, 0.0), 0.785, 0.16) * street * patch * street_hatch;
		float hz = mix(street_hatch_car * smoothstep(0.2, 0.35, amount), 1.0, smoothstep(0.7, 1.0, amount));
		if (!is_verm) o = mix(o, INK, hs * hz);
		// off-register ink ghost: ink that should be a pixel away, printed faintly here (only onto lighter ink)
		float dg = dens(texture(screen_tex, uv - ink_mis * tx).rgb);
		o = mix(o, INK, max(dg - d - 0.35, 0.0) * ink_ghost * amount);
		// off-register vermilion pass
		float vg = vden(texture(screen_tex, uv - verm_mis * tx).rgb);
		o = mix(o, VERM, vg * (is_verm ? 0.0 : 1.0) * verm_ghost * amount * (1.0 - smoothstep(0.85, 0.95, d)));
		// paper tooth: an isotropic dry-brush mottle
		float fib = vnoise(w * 0.07) * vnoise(w * 0.45 + 3.1);   // isotropic mottle (anisotropic fibres read as rain)
		float tooth = (fib - 0.25) * grain * amount;
		o = mix(o, CREAM, clamp(tooth * d * 0.35, 0.0, 1.0));
		o = mix(o, INK, clamp(-tooth * (1.0 - d) * 0.25, 0.0, 1.0));
		// aged paper: only the neutral print warms (vermilion, teal and every pickup colour keep their hue)
		float chroma = max(o.r, max(o.g, o.b)) - min(o.r, min(o.g, o.b));
		float neutral = 1.0 - smoothstep(0.12, 0.22, chroma);
		vec3 aged = clamp(o * mix(AGE_DARK, AGE_LIGHT, dot(o, vec3(0.299, 0.587, 0.114))), 0.0, 1.0);
		o = mix(o, aged, age * amount * neutral);
		COLOR = vec4(o, 1.0);
	}
}
