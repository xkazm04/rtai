shader_type canvas_item;
// Print pass for cutout PARTS (and fx / shadows / the hose line): every pixel snaps to one of the four Trivet
// inks, so the AI-painted parts print with the same paper, ink and vermilion as the ground under the riso pass.
//  - teal only where the source is clearly cyan (eyes, torch tip; DESIGN: teal = the dead + those two)
//  - vermilion where the red channel clearly leads (the collar, rust, the cape)
//  - everything else is an ink density from luminance, screened as a rotated halftone (cell px), so the art's
//    own shading survives as dots at close-up and as a tone at gameplay scale; solid ink stays solid
//  - translucent ink (drop shadows) prints as sparse ink dots
//  - paper grain multiply (same hash as the riso pass)
// (Copied from gtai-spike/cutout for the chars round; + the swap uniform for crowd palette variants.)
// rtai (f08b): ported ahead of the rig port (F-09) with the D4 flat-tint mode ON by default: mid tones print as a
// flat wash instead of a dot screen, and limb cream prints as a light wash (is_limb = 1 on limb parts) so Rivet's
// limbs separate from paper pavement at 48 px/m and up. The rig sets px_scale, limb_lod, lod_fill, is_limb per part.
// Adapted from the night lane's riso_item.gdshader (nearest-ink idea, dot function, grain).

uniform float cell = 2.0;
uniform float ink_lo = 0.30;      // ink density below this prints cream
uniform float ink_hi = 0.78;      // above this prints solid ink
uniform float px_scale = 0.34;    // screen px per part px. Small (gameplay, ~0.085): the minified art is mostly
                                  // grey blends, so the screen posterizes (thin ink outlines print SOLID, light
                                  // shading prints cream) instead of dithering into noise. Large: full halftone.
uniform float verm_gate = 62.0;   // r - max(g,b) (0..255) above which a pixel is vermilion
uniform float alpha_cut = 0.45;
uniform vec2 world_px = vec2(0.0);  // camera world offset in screen px (PartMaterials.set_world_px): tooth + dots world-locked
uniform float tint = 0.0;         // 1 = print everything vermilion (hit flash)
uniform float silhouette = 0.0;
uniform int swap = 0;           // crowd palette variants: 1 vermilion->ink, 2 vermilion->cream, 3 cream->vermilion, 4 ink->vermilion (a cop's solid plate)
uniform float lod_fill = 0.0;     // D1 sticker LOD fill: 0 = the limb_fill tint (limbs), 1 = flat vermilion (Rivet's collar), 2 = cream core
uniform float limb_fill = 0.40;   // D1 sticker LOD: the flat ink tint a limb prints at (0 = cream, 0.4 = steel)
uniform float sticker_edge = 1.3; // D1 sticker LOD: the ink outline width, screen px (taken from the part's alpha edge)
uniform float d4_flat = 1.0;     // D4 (look_d4): mid tones print as a flat wash tint, never a dot screen
uniform float is_limb = 0.0;     // D4: 1 on limb parts, whose cream prints as a light wash so it separates from paper ground
uniform float limb_wash = 0.24;  // D4: the ink tint a limb's cream prints at (full art, about 48 px/m and up)
uniform float limb_lod = 0.0;     // 1 on limb parts: at gameplay scale a 4-6 px rod of cream + outline prints as
                                  // broken lines, so limbs print SOLID INK there (the old pack sprites' trick)   // 1 = a solid cream silhouette (the readability halo under the body core)

uniform float noir = 0.0;        // D-Noir (lane noir): 1 = the body prints as one ink mass inside the halo rim
uniform float noir_keep = 0.97;   // D-Noir: source luminance above which a body pixel stays paper (visor glints)
const vec3 CREAM = vec3(0.949, 0.910, 0.835);
const vec3 VERM  = vec3(0.910, 0.314, 0.165);
const vec3 TEAL  = vec3(0.122, 0.710, 0.659);
const vec3 INK   = vec3(0.090, 0.075, 0.106);

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

float dots(vec2 frag, float cov, float ang) {
	vec2 p = mat2(vec2(cos(ang), sin(ang)), vec2(-sin(ang), cos(ang))) * frag / cell;
	return step(length(fract(p) - 0.5), sqrt(cov / 3.14159));
}

void fragment() {
	vec4 c = COLOR;
	vec2 px = FRAGCOORD.xy + world_px;
	float g = 1.0 - 0.06 * hash(floor(px));
	if (c.a < 0.04) discard;
	if (silhouette > 0.5) {
		if (c.a < 0.3) discard;
		COLOR = vec4(CREAM * g, 1.0);
	} else if (c.a < alpha_cut) {
		// translucent = shadow ink: sparse dots
		if (dots(px, c.a * 1.1, 0.785) > 0.5) COLOR = vec4(INK * g, 1.0); else discard;
	} else {
		vec3 s = c.rgb * 255.0;
		float vr = s.r - max(s.g, s.b);
		bool teal = (s.g > s.r + 60.0) && (s.b > s.r + 40.0) && (s.g > 110.0);
		float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
		float lc = dot(CREAM, vec3(0.299, 0.587, 0.114));
		float li = dot(INK, vec3(0.299, 0.587, 0.114));
		float d = clamp((lc - lum) / (lc - li), 0.0, 1.0);
		float small = 1.0 - smoothstep(0.12, 0.30, px_scale);
		float lo = mix(ink_lo, 0.36, small);
		float hi = mix(ink_hi, 0.40, small);
		vec3 o;
		if (teal) {
			o = TEAL;
		} else if (limb_lod > 0.5 && small > 0.5) {
			// D1 sticker print (was: solid ink, which made Rivet a black spider at 32 px/m): one flat value per part
			// and an ink outline from the part's own alpha edge, so the limb reads as one clean shape, not as
			// posterized fragments of its plates and bolts. The cream halo under it is the sticker rim.
			vec2 r = TEXTURE_PIXEL_SIZE * (sticker_edge / max(px_scale, 0.02));
			float e = 0.0;
			for (int k = 0; k < 8; k++) {
				float an = float(k) * 0.785398;
				e = max(e, step(texture(TEXTURE, UV + vec2(cos(an), sin(an)) * r).a, alpha_cut));
			}
			if (e > 0.5) o = INK;
			else if (lod_fill > 1.5) o = (d >= hi) ? INK : CREAM;   // core: cream sticker, only its darkest marks stay
			else if (lod_fill > 0.5) o = VERM;
			else o = mix(CREAM, INK, limb_fill);
		} else if (vr > verm_gate) {
			// dark vermilion (shaded cape folds) keeps an ink dot over the vermilion
			o = (d > 0.62 && dots(px, (d - 0.62) * 2.0, 0.785) > 0.5) ? INK : VERM;
		} else if (d >= hi) {
			o = INK;
		} else if (d <= lo) {
			o = (d4_flat > 0.5 && is_limb > 0.5) ? mix(CREAM, INK, limb_wash) : CREAM;
		} else if (d4_flat > 0.5) {
			// D4: one flat wash value for the mid tones (the art's light-grey plates), like the world's tone budget
			float cov = (d - lo) / (hi - lo);
			o = mix(CREAM, INK, mix(max(limb_wash * is_limb, 0.30), 0.62, cov));
		} else {
			float cov = (d - lo) / (hi - lo);
			o = dots(px, cov, 0.785) > 0.5 ? INK : CREAM;
		}
		if (swap == 1 && o == VERM) o = INK;
		else if (swap == 2 && o == VERM) o = CREAM;
		else if (swap == 3 && o == CREAM) o = VERM;
		else if (swap == 4 && o == INK) o = VERM;
		if (tint > 0.5 && o != INK) o = VERM;
		if (noir > 0.5) o = dot(c.rgb, vec3(0.299, 0.587, 0.114)) > noir_keep ? CREAM : INK;
		COLOR = vec4(o * g, 1.0);
	}
}
