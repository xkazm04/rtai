// Lane brutality: a burnt body (the burn signature kill). The rig part's own alpha cut, printed in
// two charcoal tones from the art's lightness, with the paper grain; the group's modulate alpha
// fades it while it crumbles. Replaces print_part on the copies only (the raw part textures are
// channel-packed and read red without a print shader).
// The rim (gunplay REQUEST 30): a light ash edge, rim_px screen pixels wide at any zoom, so the
// char body stays a body on the dark pit floor and the night paving. rim_px 0 = no rim (the
// mini-nuke's shadow uses that: a shadow burnt into the street has no lit edge).
shader_type canvas_item;

uniform vec3 char_hi : source_color = vec3(0.32, 0.28, 0.27);
uniform vec3 char_lo : source_color = vec3(0.09, 0.075, 0.09);
uniform vec3 rim_color : source_color = vec3(0.80, 0.76, 0.70);
uniform float rim_px = 1.6;
uniform float alpha_cut = 0.3;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

// 1 where a texel within rim_px screen pixels lies outside the part's alpha cut.
float edge(sampler2D tex, vec2 uv, vec2 d) {
	if (rim_px <= 0.0) return 0.0;
	float out_n = 0.0;
	for (int i = 0; i < 8; i++) {
		float a = float(i) * 0.785398;
		out_n += step(texture(tex, uv + d * vec2(cos(a), sin(a))).a, alpha_cut);
	}
	return clamp(out_n, 0.0, 1.0);
}

void fragment() {
	vec2 d = fwidth(UV) * rim_px;  // before the discard: derivatives need the whole quad
	vec4 t = texture(TEXTURE, UV);
	if (t.a < alpha_cut) discard;
	float fade = COLOR.a / max(t.a, 0.001);
	float lum = dot(t.rgb, vec3(0.299, 0.587, 0.114));
	float g = 1.0 - 0.08 * hash(floor(UV / TEXTURE_PIXEL_SIZE));  // grain locked to the part
	vec3 o = lum > 0.62 ? char_hi : char_lo;
	o = mix(o, rim_color, edge(TEXTURE, UV, d));
	COLOR = vec4(o * g, clamp(fade, 0.0, 1.0));
}
