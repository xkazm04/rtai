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
uniform float grime = 0.10;
uniform float ink_at = 0.74;       // density above which the art's (mip-softened) pen lines print solid ink        // dry-brush grime blotches
uniform float rust_lod = 3.0;      // mip level the rust must survive at (kills isolated specks: no shimmer)
uniform float tint = 0.0;         // 1 = hit flash (everything not ink prints vermilion)

const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 VERM = vec3(0.910, 0.314, 0.165);
const vec3 TEAL = vec3(0.122, 0.710, 0.659);
const vec3 INK = vec3(0.090, 0.075, 0.106);
const vec3 STEEL_HI = vec3(0.780, 0.745, 0.780);
const vec3 STEEL_MID = vec3(0.560, 0.520, 0.585);
const vec3 STEEL_LO = vec3(0.330, 0.295, 0.355);

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
	if (c.a < 0.04) discard;
	vec2 g_px = floor(FRAGCOORD.xy);
	float g = 1.0 - 0.06 * hash(g_px);
	if (c.a < alpha_cut || amount < 0.004) {
		discard;   // an overlay: the D4 part under it prints the edge, the halo and the shadow
	} else {
		vec3 s = c.rgb;
		float d = dens(s);
		bool teal = (s.g > s.r + 0.23) && (s.b > s.r + 0.16) && (s.g > 0.43);
		vec2 q = UV / TEXTURE_PIXEL_SIZE * px_scale;   // part space in screen px: hatch rotates with the part
		vec3 o;
		if (teal) {
			o = TEAL;
		} else if (red_lead(s) > verm_gate && red_lead(textureLod(TEXTURE, UV, rust_lod).rgb) > verm_gate * 0.6) {
			o = d > 0.72 ? mix(VERM, INK, 0.55) : VERM;
		} else {
			o = mix(CREAM, STEEL_HI, smoothstep(0.08, 0.16, d));
			o = mix(o, STEEL_MID, smoothstep(0.42, 0.50, d));
			o = mix(o, STEEL_LO, smoothstep(0.62, 0.70, d));
			float ink = smoothstep(ink_at, ink_at + 0.06, d);
			ink = max(ink, strokes(q, 0.785, smoothstep(hatch_lo, hatch_lo + 0.25, d) * 0.36) * step(hatch_lo, d));
			ink = max(ink, strokes(q, 2.356, smoothstep(hatch_hi, hatch_hi + 0.2, d) * 0.34) * step(hatch_hi, d));
			o = mix(o, INK, ink);
			// the off-register plate: vermilion that should be under a nearby edge, printed here
			vec2 off = TEXTURE_PIXEL_SIZE * (mis_px / max(px_scale, 0.02)) * vec2(0.8, -0.6);
			vec3 s2 = texture(TEXTURE, UV + off).rgb;
			float a2 = texture(TEXTURE, UV + off).a;
			float rv = smoothstep(verm_gate, verm_gate + 30.0, red_lead(s2)) * step(0.5, a2);
			o = mix(o, VERM, rv * mis_k * (1.0 - ink));
			// paper grime: blotchy dry-brush in part space
			float gr = vnoise(q * 0.35) * vnoise(q * 1.7 + 3.0);
			o = mix(o, INK, smoothstep(0.48, 0.66, gr) * grime);
		}
		if (tint > 0.5 && o != INK) o = VERM;
		COLOR = vec4(o * g, amount);
	}
}
