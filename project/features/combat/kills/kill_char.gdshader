// Lane brutality: a burnt body (the burn signature kill). The rig part's own alpha cut, printed in
// two charcoal tones from the art's lightness, with the paper grain; the group's modulate alpha
// fades it while it crumbles. Replaces print_part on the copies only (the raw part textures are
// channel-packed and read red without a print shader).
shader_type canvas_item;

uniform vec3 char_hi : source_color = vec3(0.32, 0.28, 0.27);
uniform vec3 char_lo : source_color = vec3(0.09, 0.075, 0.09);
uniform float alpha_cut = 0.3;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	if (t.a < alpha_cut) discard;
	float fade = COLOR.a / max(t.a, 0.001);
	float lum = dot(t.rgb, vec3(0.299, 0.587, 0.114));
	float g = 1.0 - 0.08 * hash(floor(FRAGCOORD.xy));
	vec3 o = lum > 0.62 ? char_hi : char_lo;
	COLOR = vec4(o * g, clamp(fade, 0.0, 1.0));
}
