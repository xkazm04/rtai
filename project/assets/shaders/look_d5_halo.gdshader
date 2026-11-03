shader_type canvas_item;
// PROPOSAL (d5-close iteration 7) for the characters lane: the thin INK line OUTSIDE the cream sticker rim that the
// target frame (d4h2_mock.jpg) draws around every character. Ours go rim -> street, so on the cream zebra and
// pavement only the inner ink line separates a character from the ground. Drawn by a child sprite of each halo
// (same texture and transform), z below every halo, so where halos overlap the cream covers the ring and only the
// silhouette's outer edge gets the line. Ring width is in SCREEN px (UV derivatives), so it holds under the halo's
// non-uniform limb scale and the part rotations. Dev A/B: D5_HALO=ink with dev/showcase/d5_hero.gd.

uniform float line_px = 1.0;   // ring width, screen px
uniform float cut = 0.3;       // = print_part.gdshader's silhouette alpha cut (the cream rim's edge)

const vec3 INK = vec3(0.090, 0.075, 0.106);

void fragment() {
	vec2 dx = dFdx(UV) * line_px;
	vec2 dy = dFdy(UV) * line_px;
	float a = texture(TEXTURE, UV).a;
	float m = 0.0;
	for (int k = 0; k < 8; k++) {
		float an = float(k) * 0.785398;
		m = max(m, texture(TEXTURE, UV + dx * cos(an) + dy * sin(an)).a);
	}
	if (a >= cut || m < cut) {
		discard;
	}
	COLOR = vec4(INK, 1.0);
}
