// ghost-forms: a speaking ghost's apparition (GhostApparition). Every part of the ghost's own rig
// copy draws through this material instead of the print: the part's ink stays a deep teal, its
// paper and steel go pale teal, so the ghost reads as the same body made of soul light. Rim parts
// (`silhouette` = 1, the cream sticker rims) print as a flat pale-teal glow edge. Faint scan bands
// (the voice as radio static) drift with `band_phase`. Alpha comes from the node's modulate.
// (Per part, not a CanvasGroup: the rigs' parts carry their own z_index, which escapes a group.)
shader_type canvas_item;
render_mode unshaded;

uniform vec3 deep : source_color = vec3(0.04, 0.27, 0.28);
uniform vec3 hi : source_color = vec3(0.72, 1.0, 0.95);
uniform float silhouette = 0.0;
uniform float band_phase = 0.0;
uniform float band_k = 0.2;

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	float l = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 rgb = mix(deep, hi, smoothstep(0.04, 0.62, l));
	rgb = mix(rgb, hi, silhouette);
	float a = c.a * mix(1.0, 0.55, silhouette);
	float band = 1.0 - band_k * step(0.5, fract(SCREEN_UV.y * 80.0 + band_phase));
	COLOR = vec4(rgb, a * band);
}
