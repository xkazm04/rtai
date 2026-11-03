shader_type canvas_item;
// PROPOSAL (d5-close iteration 7) for the characters lane: the thin INK line OUTSIDE the cream sticker rim that the
// target frame (d4h2_mock.jpg) draws around every character, and (optional) its soft drop shadow down-right, the
// same light as the buildings' cast shadows. Ours go rim -> street, so on the cream zebra and pavement only the
// inner ink line separates a character from the ground. Drawn by a child sprite of each halo (same texture and
// transform), z below every halo, so where halos overlap the cream covers ring and shadow and only the silhouette's
// outer edge gets them. Widths are SCREEN px (UV derivatives), so they hold under the halo's non-uniform limb scale
// and the part rotations. Dev A/B: D5_HALO=ink (D5_HALO_SHADOW=1 for the shadow) with dev/showcase/d5_hero.gd.

uniform float line_px = 1.0;               // ring width, screen px
uniform float cut = 0.3;                   // = print_part.gdshader's silhouette alpha cut (the cream rim's edge)
uniform vec2 shadow_px = vec2(0.0);        // drop shadow offset, screen px (0 = no shadow)
uniform float shadow_blur = 1.5;           // shadow softness, screen px
uniform float shadow_a = 0.0;              // shadow ink opacity
uniform float fade = 1.0;                  // follows the halo's own shrink (CutRig hk), so nothing pops where halos hide

const vec3 INK = vec3(0.090, 0.075, 0.106);

void fragment() {
	vec2 dx = dFdx(UV);
	vec2 dy = dFdy(UV);
	float a = texture(TEXTURE, UV).a;
	float m = 0.0;
	float s = 0.0;
	vec2 sc = UV - dx * shadow_px.x - dy * shadow_px.y;
	s += step(cut, texture(TEXTURE, sc).a);
	for (int k = 0; k < 8; k++) {
		float an = float(k) * 0.785398;
		vec2 dir = dx * cos(an) + dy * sin(an);
		m = max(m, texture(TEXTURE, UV + dir * line_px).a);
		s += step(cut, texture(TEXTURE, sc + dir * shadow_blur).a);
	}
	float sh = (s / 9.0) * shadow_a * step(0.01, length(shadow_px)) * fade;
	if (a >= cut) {
		discard;
	}
	if (m >= cut) {
		COLOR = vec4(INK, fade);
	} else if (sh > 0.004) {
		COLOR = vec4(INK, sh);
	} else {
		discard;
	}
}
