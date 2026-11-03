shader_type canvas_item;
// D5 "Inked Grime": the part print for the D5 detail tier (features/characters/art/d5/<char>/): RigDetail draws one
// overlay sprite per part with this material on top of the D4 part, faded in from 56 to 64 px/m (amount = alpha).
// The D5 art is drawn with fine pen hatching, rust and a misregistered vermilion plate; at arena zoom a part is
// still minified ~5x, so the art's own hatch lines mip down to grey. This print therefore:
//  - maps the art's tone to a 4-step violet-grey steel ramp (the concept's lavender steel, inside the B/W doctrine:
//    it is the D4 wash ink, never a hue)
//  - RE-DRAWS the hatch at screen resolution in the part's own space (so it rotates with the limb and never swims):
//    one stroke family in the mid tones, a cross family in the darks, with ink-pressure wobble
//  - prints vermilion where the art's red leads (collar stripes, rust streaks), and a second vermilion plate
//    knocked off-register by mis_px screen px (the concept's misprint), only along dark edges
//  - teal only where the source is clearly cyan (torch tip, visor)
// Silhouette, sticker halo and outline are the D4 part's (the D5 alpha is the D4 alpha), so the tier switch never
// moves an outline. Params: look_d5.params.json ("part").

uniform float px_scale = 0.2;     // screen px per part px (PartMaterials.view_px)
uniform float amount = 1.0;       // 0..1 overlay alpha over the D4 part (the zoom fade, RigDetail)
uniform float hatch_period = 3.6; // screen px between strokes
uniform float hatch_lo = 0.50;    // density where the first stroke family starts
uniform float hatch_hi = 0.70;    // density where the cross family starts
uniform float mis_px = 2.0;       // off-register vermilion plate offset, screen px
uniform float mis_k = 0.55;       // strength of the off-register plate
uniform float verm_gate = 48.0;   // r - max(g,b) (0..255) above which a pixel is vermilion
uniform float alpha_cut = 0.45;
uniform float grime = 0.10;        // dry-brush grime blotches
uniform float ink_at = 0.74;       // density above which the (mip-softened) pen lines print solid ink
uniform float plate_lod = 5.0;     // mip level at which a vermilion PLATE (the collar) is still vermilion
uniform float rust_dry = 0.55;     // rust prints as vermilion mixed this far toward ink
uniform float rust_lod = 3.0;      // mip level the rust must survive at (kills isolated specks: no shimmer)
uniform float shade_px = 8.0;     // width of the hatched shadow band on each part's lower-right edge, screen px
uniform float shade_k = 0.26;     // stroke coverage in that band (0 = off)
uniform float verm_shade = 0.7;   // the form-shade hatch also over vermilion plates (cop bodies, the collar)
uniform float lit_k = 0.55;       // cream lit rim on the upper-left edge (keeps the part's mean tone vs the street)
uniform float fringe_k = 0.0;    // OPTION (owner A/B, iteration 8): the concept's off-register vermilion along each
                                  // part's down-right edge, inside the outline, broken like a misprint (0 = off)
uniform float fringe_art = 22.0;  // that band's depth in PART px (the art's outline is drawn in part px too)
uniform vec2 fringe_fade = vec2(0.2, 0.3); // px_scale where it starts / is full (64 -> 96 px/m: busy at 64)
uniform float fringe_dry = 0.2;   // the misprint's vermilion mixed this far toward ink (the collar stays the purest)
uniform float dots_k = 0.0;       // OPTION (owner A/B, iteration 8): the concept's halftone dot screen in the steel
                                  // mid-tones (violet-grey dots, part space: no swim), fading in with fringe_fade
uniform float dots_period = 3.0;  // screen px between dots
uniform float tint = 0.0;         // 1 = hit flash (everything not ink prints vermilion)

const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 VERM = vec3(0.910, 0.314, 0.165);
const vec3 TEAL = vec3(0.122, 0.710, 0.659);
const vec3 INK = vec3(0.090, 0.075, 0.106);
// d5-cast (2026-11-03): the police inks (palette.json cop_blue / cop_blue_hi), as print_part.gdshader
const vec3 COP_BLUE = vec3(0.227, 0.278, 0.400);
const vec3 COP_BLUE_HI = vec3(0.310, 0.525, 0.878);
const vec3 STEEL_HI = vec3(0.915, 0.880, 0.890);
const vec3 STEEL_MID = vec3(0.740, 0.700, 0.760);
const vec3 STEEL_LO = vec3(0.420, 0.385, 0.450);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float dens(vec3 c) {
	float lum = dot(c, vec3(0.299, 0.587, 0.114));
	float lc = dot(CREAM, vec3(0.299, 0.587, 0.114));
	float li = dot(INK, vec3(0.299, 0.587, 0.114));
	return clamp((lc - lum) / (lc - li), 0.0, 1.0);
}

float red_lead(vec3 c) { return c.r * 255.0 - max(c.g, c.b) * 255.0; }

// a family of pen strokes in part space q (screen px units), coverage cov, ink-pressure wobble
float strokes(vec2 q, float ang, float cov) {
	vec2 dir = vec2(cos(ang), sin(ang));
	float along = dot(q, vec2(-dir.y, dir.x));
	float across = dot(q, dir) + (vnoise(vec2(along * 0.09, ang * 5.0)) - 0.5) * 1.1;
	float f = abs(fract(across / hatch_period) - 0.5) * 2.0;
	float press = 0.75 + 0.5 * vnoise(vec2(along * 0.05, floor(across / hatch_period) * 2.3));
	return 1.0 - smoothstep(cov * press - 0.18, cov * press + 0.18, f);
}

void fragment() {
	vec4 c = COLOR;
	// form shadow: a hatched band inside the part's lower-right edge in SCREEN space (the world's light, as the
	// roofs and cast shadows), found by stepping the alpha toward the light's far side (derivatives taken here, in
	// uniform control flow, before any discard or branch)
	vec2 off_s = (dFdx(UV) + dFdy(UV)) * shade_px * 0.7071;
	float far = 1.0 - step(alpha_cut, texture(TEXTURE, UV + off_s).a);
	float near = 1.0 - step(alpha_cut, texture(TEXTURE, UV + off_s * 0.5).a);
	float shade = clamp(far * 0.6 + near * 0.4, 0.0, 1.0);
	// the misprint shifts in PRINT space (screen down-right, as the shade band) but its depth is in part px
	vec2 dir_s = dFdx(UV) + dFdy(UV);
	vec2 off_f = dir_s / max(length(dir_s / TEXTURE_PIXEL_SIZE), 1e-4) * fringe_art;
	float fringe = 1.0 - step(alpha_cut, texture(TEXTURE, UV + off_f).a);
	if (c.a < 0.04) discard;
	vec2 g_px = floor(UV / TEXTURE_PIXEL_SIZE * px_scale);   // paper grain locked to the part, never to the screen (no swim)
	float g = 1.0 - 0.06 * hash(g_px);
	if (c.a < alpha_cut || amount < 0.004) {
		discard;   // an overlay: the D4 part under it prints the edge, the halo and the shadow
	} else {
		vec3 s = c.rgb;
		float d = dens(s);
		bool teal = (s.g > s.r + 0.23) && (s.b > s.r + 0.16) && (s.g > 0.43) && (s.b - s.g < 0.157);  // not a bright cop blue
		vec2 q = UV / TEXTURE_PIXEL_SIZE * px_scale;   // part space in screen px: hatch rotates with the part
		vec3 o;
		if (teal) {
			o = TEAL;
		} else if (red_lead(s) > verm_gate && red_lead(textureLod(TEXTURE, UV, rust_lod).rgb) > verm_gate * 0.6) {
			// pure vermilion only where it is coherent at a coarse mip (the hazard collar = Rivet's signature);
			// rust streaks print as dried rust, a vermilion-ink mix, so they never compete with the collar
			bool plate = red_lead(textureLod(TEXTURE, UV, plate_lod).rgb) > verm_gate * 0.6;
			o = plate ? VERM : mix(VERM, INK, rust_dry);
			o = d > 0.72 ? mix(o, INK, 0.55) : o;
			o = mix(o, INK, strokes(q, 0.785, shade * shade_k * verm_shade));
		} else if (s.b - max(s.r, s.g) >= (dens(s) < 0.55 ? 0.196 : 0.086) && s.g >= s.r) {
			// cop blue: the uniform plate (navy) and the small marks (light), hatched like the vermilion plates
			o = dot(s, vec3(0.299, 0.587, 0.114)) > 0.40 ? COP_BLUE_HI : COP_BLUE;
			o = d > 0.86 ? mix(o, INK, 0.6) : o;
			o = mix(o, INK, strokes(q, 0.785, shade * shade_k * verm_shade));
		} else {
			o = mix(CREAM, STEEL_HI, smoothstep(0.08, 0.16, d));
			o = mix(o, STEEL_MID, smoothstep(0.42, 0.50, d));
			o = mix(o, STEEL_LO, smoothstep(0.62, 0.70, d));
			float ink = smoothstep(ink_at, ink_at + 0.06, d);
			ink = max(ink, strokes(q, 0.785, smoothstep(hatch_lo, hatch_lo + 0.25, d) * 0.36) * step(hatch_lo, d));
			ink = max(ink, strokes(q, 2.356, smoothstep(hatch_hi, hatch_hi + 0.2, d) * 0.34) * step(hatch_hi, d));
			float lit = 1.0 - step(alpha_cut, texture(TEXTURE, UV - off_s * 0.45).a);
			o = mix(o, CREAM, lit * (1.0 - shade) * lit_k * (1.0 - smoothstep(0.5, 0.7, d)));
			o = mix(o, STEEL_MID, shade * 0.12);
			ink = max(ink, strokes(q, 0.785, shade * shade_k));
			o = mix(o, INK, ink);
			// the off-register plate: vermilion that should be under a nearby edge, printed here
			vec2 off = TEXTURE_PIXEL_SIZE * (mis_px / max(px_scale, 0.02)) * vec2(0.8, -0.6);
			vec3 s2 = texture(TEXTURE, UV + off).rgb;
			float a2 = texture(TEXTURE, UV + off).a;
			float rv = smoothstep(verm_gate, verm_gate + 30.0, red_lead(s2)) * step(0.5, a2);
			o = mix(o, VERM, rv * mis_k * (1.0 - ink));
			float fk = fringe_k * smoothstep(fringe_fade.x, fringe_fade.y, px_scale);
			float brk = smoothstep(0.30, 0.45, vnoise(q * vec2(0.22, 0.31) + 7.0));   // the misprint drops out
			float cool = step(s.r - 0.03, s.b);   // steel only: on a cream glove a red edge reads as blood
			o = mix(o, mix(VERM, INK, fringe_dry), fringe * brk * fk * cool * (1.0 - ink));
			float band = smoothstep(0.26, 0.44, d) * (1.0 - smoothstep(0.62, 0.74, d)) * (0.45 + 0.55 * shade);
			vec2 cell = fract(mat2(vec2(0.966, 0.259), vec2(-0.259, 0.966)) * q / dots_period) - 0.5;
			float rad = 0.5 * sqrt(band * 0.55);
			float dot = 1.0 - smoothstep(rad - 0.1, rad + 0.1, length(cell));
			o = mix(o, STEEL_LO, dot * dots_k * smoothstep(fringe_fade.x, fringe_fade.y, px_scale) * (1.0 - ink));
			// paper grime: blotchy dry-brush in part space
			float gr = vnoise(q * 0.35) * vnoise(q * 1.7 + 3.0);
			o = mix(o, INK, smoothstep(0.48, 0.66, gr) * grime);
		}
		if (tint > 0.5 && o != INK) o = VERM;
		COLOR = vec4(o * g, amount);
	}
}
