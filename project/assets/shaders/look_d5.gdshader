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
// the value-noise lattice (n-visual core/render/grime_lattice.gd, 128 x 128; LookOverlay sets it)
uniform sampler2D grime_tex : filter_linear, repeat_enable;
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
uniform float age_floor = 0.0;     // aged paper below the D5 zoom (32 px/m too): a proposal for the D4 profile, 0 = off
uniform float grain_floor = 0.0;   // the world-locked paper tooth below the D5 zoom (the mock's mottle): a proposal, 0 = off
// n5-look riso (targets 2026-11-04 r2_a5): the middle-ground dial. 0 = the d5 print bit-identical; it scales the
// halftone, the colour-plate offset and the paper fibre at every zoom (not by `amount`: they live at 32 px/m)
uniform float riso = 0.0;
uniform float dot_k = 0.3;         // halftone contrast in the mid-tone fills (the mean tone is kept)
uniform float dot_period = 4.0;    // screen px between dot centres along the 45-degree screen
uniform float dot_patchy = 0.0;    // uneven riso inking: the dot contrast dips in soft world-locked patches (0 = even)
uniform float plate_k = 0.5;       // colour-plate misregistration: ghost + paper sliver strength
uniform vec2 plate_mis = vec2(1.0, -1.0); // the colour plate's offset in screen px
uniform float fibre_k = 0.5;       // paper fibre strength (dark and light strands)
uniform float fibre_scale = 0.09;  // fibre lattice frequency per screen px
uniform float stain_k = 0.0;       // low-frequency grey-brown stains on the paper (the target's mottled sheet)
uniform float stain_scale = 0.011; // stain lattice frequency per screen px
uniform float tan_k = 0.0;         // the ground's light neutral print toned toward the target's tan sheet (actors untouched)
uniform vec3 tan_tone = vec3(0.92, 0.875, 0.8); // the sheet tone tan_k multiplies the light ground by
uniform float speck_k = 0.0;       // riso toner speckle: sparse 1 px ink specks on the paper and light fills (0 = off)
uniform float speck_density = 0.05; // the share of light pixels that take a speck where the cluster noise peaks

// the print inks from palette.json (visual-engine's LookOverlay sets them, like look_d4's tones)
uniform vec3 paper_tone = vec3(0.949, 0.910, 0.835);
uniform vec3 ink_tone = vec3(0.090, 0.075, 0.106);
const vec3 VERM = vec3(0.910, 0.314, 0.165);
// aged-paper gains, dark end and light end (d4h2_mock.jpg medians: street 78,67,68 / paper 246,223,195)
const vec3 AGE_DARK = vec3(1.03, 0.955, 0.87);
const vec3 AGE_LIGHT = vec3(1.065, 1.0, 0.955);

// value noise on the baked lattice: bilinear at i + smoothstep(f) = the smoothstep-faded value noise of
// the sin hash, 1 fetch instead of 4 hashes (the low-end GPU cost; n-visual core/render/README.md)
float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	return texture(grime_tex, (i + f * f * (3.0 - 2.0 * f) + 0.5) / 128.0).r;
}

float dens(vec3 c) { return clamp((0.93 - dot(c, vec3(0.299, 0.587, 0.114))) * 1.2, 0.0, 1.0); }

float vden(vec3 c) { return clamp((c.r - max(c.g, c.b) - 0.25) * 3.0, 0.0, 1.0); }

float chroma(vec3 c) { return max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); }

// world-locked 45-degree dot screen: 1 inside a dot whose area is `cov` of the cell
float halftone(vec2 w, float cov) {
	vec2 r = vec2(w.x + w.y, w.x - w.y) * (0.70710678 / dot_period);
	float dist = length(fract(r) - 0.5);
	float rad = sqrt(cov * 0.3183);
	return 1.0 - smoothstep(rad - 0.1, rad + 0.1, dist);
}

// ridged value noise: thin wandering strands where the lattice crosses its mid value
float strand(vec2 p) {
	return smoothstep(0.92, 0.985, 1.0 - abs(vnoise(p) * 2.0 - 1.0));
}

// the riso layer: halftone in the mid-tone fills, the colour plate off register, paper fibre
vec3 riso_print(vec3 o, vec3 c, float d, vec2 w, vec2 uv, vec2 tx) {
	float tone = smoothstep(0.08, 0.2, d) * (1.0 - smoothstep(0.88, 0.97, d));
	if (tone > 0.0 && vden(c) < 0.3) {
		float cov = clamp(d, 0.05, 0.95);
		float ink = 1.0 - dot_patchy * smoothstep(0.35, 0.7, vnoise(w * 0.035 + 21.7));
		o = clamp(o * (1.0 + (cov - halftone(w, cov)) * dot_k * riso * tone * ink), 0.0, 1.0);
	}
	// the colour plate printed plate_mis px off: its ghost on the neutral print, a paper sliver opposite
	vec3 cg = texture(screen_tex, uv - plate_mis * tx).rgb;
	vec3 cs = texture(screen_tex, uv + plate_mis * tx).rgb;
	float ch = chroma(c);
	float gh = max(chroma(cg) - ch - 0.1, 0.0) * step(vden(cg), 0.3);
	o = mix(o, o * (cg / max(max(cg.r, max(cg.g, cg.b)), 0.05)), clamp(gh * 3.0, 0.0, 1.0) * plate_k * riso);
	float sl = max(ch - chroma(cs) - 0.1, 0.0) * step(vden(c), 0.3);
	o = mix(o, mix(o, paper_tone, 0.55), clamp(sl * 3.0, 0.0, 1.0) * plate_k * riso);
	// paper fibre: two strand families at different scales, dark on paper, light in the ink
	// (each family broken into short fragments by a coarse mask: unbroken, the strands read as a contour map)
	float f1 = strand(w * fibre_scale + 5.3) * smoothstep(0.58, 0.8, vnoise(w * 0.045 + 1.7));
	float f2 = strand(w.yx * fibre_scale * 1.6 + 9.1) * smoothstep(0.55, 0.8, vnoise(w * 0.05 + 4.2));
	o = mix(o, ink_tone, f1 * fibre_k * riso * 0.2 * (1.0 - d));
	o = mix(o, paper_tone, f2 * fibre_k * riso * 0.18 * (0.35 + d));
	// toner speckle (r2_a5's grain, toned down): a per-pixel lattice hash, thinned by a cluster mottle
	if (speck_k > 0.0 && d < 0.45) {
		vec2 p = floor(w);
		float h = fract(texture(grime_tex, (p + 0.5) / 128.0).r * 7.31 + texture(grime_tex, (floor(p / 3.0) + 37.5) / 128.0).r * 13.7);
		float cl = smoothstep(0.3, 0.75, vnoise(w * 0.06 + 8.3));
		o = mix(o, ink_tone, step(1.0 - speck_density * cl, h) * speck_k * riso * (1.0 - d / 0.45));
	}
	// tan sheet: only the light neutral ground (the cream actors draw above this layer and pop more)
	float neu = 1.0 - smoothstep(0.12, 0.22, chroma(o));
	o = mix(o, clamp(o * tan_tone, 0.0, 1.0), tan_k * riso * neu * (1.0 - smoothstep(0.3, 0.7, d)));
	// stains: soft blotches with a darker tide line, on the paper and light fills only (never a red: a neutral dirt)
	if (stain_k > 0.0 && d < 0.5) {
		float sn = vnoise(w * stain_scale + 11.3) * 0.65 + vnoise(w * stain_scale * 3.7 + 6.1) * 0.35;
		float st = smoothstep(0.6, 0.68, sn) * (0.5 + 0.5 * vnoise(w * 0.11 + 2.9));
		st += smoothstep(0.02, 0.0, abs(sn - 0.6)) * 0.7;
		o = mix(o, o * vec3(0.84, 0.81, 0.78), clamp(st, 0.0, 1.0) * stain_k * riso * (1.0 - smoothstep(0.3, 0.5, d)));
	}
	return o;
}

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
	if (amount < 0.004 && age_floor < 0.004 && grain_floor < 0.004 && riso < 0.004) {
		COLOR = vec4(c, 1.0);
	} else {
		float d = dens(c);
		bool is_verm = vden(c) > 0.3;
		vec3 o = c;
		// ink pressure: a second family over the mid and dark wash (never on paper, never on solid ink)
		float wash = smoothstep(wash_lo, wash_lo + 0.12, d) * (1.0 - smoothstep(wash_hi, wash_hi + 0.1, d));
		float street = smoothstep(wash_hi + 0.05, wash_hi + 0.15, d) * (1.0 - smoothstep(0.88, 0.95, d));
		// early-outs (bit-identical): the noise behind a mask that is exactly 0 is not evaluated; amount 0
		// (only the age / grain floors live, below the D5 zoom) skips the strokes and both ghosts
		if (!is_verm && amount > 0.0 && (wash > 0.0 || street > 0.0)) {
			float patch = smoothstep(0.42, 0.72, vnoise(w * 0.018 + 7.0));   // hand pressure comes and goes in patches
			if (wash > 0.0) {
				float h = strokes(w, -0.62, mix(0.16, 0.34, smoothstep(0.3, 0.6, d))) * wash * patch * hatch;
				o = mix(o, ink_tone, h * amount);
			}
			// the street (dark wash): sparse, darker pen strokes, only at full amount (64 px/m+), the mock's hatched asphalt
			if (street > 0.0) {
				float hs = strokes(w + vec2(3.0, 0.0), 0.785, 0.16) * street * patch * street_hatch;
				float hz = mix(street_hatch_car * smoothstep(0.2, 0.35, amount), 1.0, smoothstep(0.7, 1.0, amount));
				o = mix(o, ink_tone, hs * hz);
			}
		}
		// off-register ink ghost: ink that should be a pixel away, printed faintly here (only onto lighter ink)
		if (amount > 0.0 && d < 0.66) {
			float dg = dens(texture(screen_tex, uv - ink_mis * tx).rgb);
			o = mix(o, ink_tone, max(dg - d - 0.35, 0.0) * ink_ghost * amount);
		}
		// off-register vermilion pass
		if (!is_verm && amount > 0.0 && d < 0.95) {
			float vg = vden(texture(screen_tex, uv - verm_mis * tx).rgb);
			o = mix(o, VERM, vg * verm_ghost * amount * (1.0 - smoothstep(0.85, 0.95, d)));
		}
		// paper tooth: an isotropic dry-brush mottle
		float fib = vnoise(w * 0.07) * vnoise(w * 0.45 + 3.1);   // isotropic mottle (anisotropic fibres read as rain)
		float tooth = (fib - 0.25) * max(grain * amount, grain_floor);
		o = mix(o, paper_tone, clamp(tooth * d * 0.35, 0.0, 1.0));
		o = mix(o, ink_tone, clamp(-tooth * (1.0 - d) * 0.25, 0.0, 1.0));
		if (riso > 0.0) {
			o = riso_print(o, c, d, w, uv, tx);
		}
		// aged paper: only the neutral print warms (vermilion, teal and every pickup colour keep their hue)
		float chroma = max(o.r, max(o.g, o.b)) - min(o.r, min(o.g, o.b));
		float neutral = 1.0 - smoothstep(0.12, 0.22, chroma);
		vec3 aged = clamp(o * mix(AGE_DARK, AGE_LIGHT, dot(o, vec3(0.299, 0.587, 0.114))), 0.0, 1.0);
		o = mix(o, aged, max(age * amount, age_floor) * neutral);
		COLOR = vec4(o, 1.0);
	}
}
